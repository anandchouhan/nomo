class User < ApplicationRecord
  # acts_as_voter
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]

  belongs_to :hometown, class_name: "Location", optional: true
  belongs_to :location, class_name: "Location", optional: true

  enum location_privacy: %i(only_me friends friends_of_friends global)

  has_many :notifications, class_name: :Notification, foreign_key: :recipient_user_id, dependent: :destroy
  has_many :trips, dependent: :destroy
  has_many :comments
  has_many :communities
  has_many :user_settings, dependent: :destroy
  has_many :friend_requests, foreign_key: :recipient_user_id, dependent: :destroy
  has_many :sent_friend_requests, class_name: :FriendRequest, foreign_key: :sender_user_id, dependent: :destroy
  has_many :requests_to_join, dependent: :destroy, inverse_of: :user

  has_many :friendships, foreign_key: :origin_user_id, dependent: :destroy
  has_many :friends, through: :friendships, source: :destination
  validates :email, presence: true, uniqueness: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :name, presence: true  
  # validates :username  format: { with: /\A[a-zA-Z0-9_-]*\z/, message: "username is invalid, please provide letters, numbers or '-' and '_' symbols" }
  validates :username, uniqueness: true
  validates :date_of_birth, presence: true, on: :create
  validate :at_least_16
  
  after_create :set_account_created, :set_default_username
  after_create_commit :send_welcome_email
  before_save :user_profile_picture

  def upcoming_trips
    Trip.joins("INNER JOIN trip_locations ON trip_locations.trip_id = trips.id").
      joins("INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id").
      where("trip_locations.end_at >= ? AND trip_location_participants.user_id = ?", Time.zone.now - 1.day, id).
      distinct
  end

  def upcoming_trip_locations
    TripLocation.joins("INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id").
      where("trip_locations.end_at >= ? AND trip_location_participants.user_id = ?", Time.zone.now - 1.day, id).
      distinct
  end

  def trips_participating
    Trip.joins("INNER JOIN trip_locations ON trip_locations.trip_id = trips.id").
      joins("INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id").
      where("trip_location_participants.user_id = ?", id).
      distinct
  end

  def friend_of?(user)
    friends.include?(user)
  end

  def friend_of_friend?(user)
    friends.each do |friend|
      if friend.friends.where(destination_user: user).any?
        return true
      end
    end

    false
  end

  def friend_request_sent?(user)
    sent_friend_requests.where(recipient: user).any?
  end

  def friend_request_received?(user)
    friend_requests.where(sender: user).any?
  end

  def has_requested_to_join?(trip_location)
    requests_to_join.where(trip_location: trip_location).any?
  end

  # Checks if this user can see the location of the user passed as a parameter
  def can_see_location?(user)
    if self == user || user.location_privacy == "global"
      true
    elsif user.location_privacy == "friends_of_friends"
      if user.friend_of?(self) || user.friend_of_friend?(self)
        true
      else
        false
      end
    elsif user.location_privacy == "friends" && user.friend_of?(self)
      true
    else
      false
    end
  end

  def profile_image
    if oauth_token.present?
      fb_image
    else
      "https://s3.us-east-2.amazonaws.com/nomofomo-assets/static/images/user.png"
    end
  end

  def first_name
    if name
      name.split(" ").first
    elsif username
      username
    end
  end

  # Used when the user is searching a user in the Find Friends modal
  def self.lookup(search)
    like = "%" + search + "%"
    User.where("name ILIKE ? OR email ILIKE ?", like, like).distinct.order(:name).take(10)
  end

  def fb_freinds
    access_token = oauth_token
    if access_token.present?
      appsecret_proof = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), ENV["FACEBOOK_SECRET"], access_token)

      fb_url = "?access_token=#{access_token}&appsecret_proof=#{appsecret_proof}"
      uri = "https://graph.facebook.com/me/friends/#{fb_url}"
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      begin
        fb_req = Net::HTTP::Get.new(uri.request_uri)
        fb_response = http.request(fb_req)
        res = JSON.parse fb_response.response.body
        ids = res["data"].map { |p| p["id"] }
      rescue StandardError
        ids = []
      end
    else
      ids = []
    end
    User.where(uid: ids).order(:name).take(10)
  end

  # Removes the 'friendship' relationship between two users.
  # Friendship does not exist when one of the users removes the friendship,
  # and the another user removes the friendship too without reloading the page.
  def self.unfriend(first_user_id, second_user_id)
    ActiveRecord::Base.transaction do
      Friendship.where("origin_user_id = ? AND destination_user_id = ?", first_user_id, second_user_id).take&.destroy
      Friendship.where("origin_user_id = ? AND destination_user_id = ?", second_user_id, first_user_id).take&.destroy
    end
  end

  private

  def set_default_username
    if username.blank?
      exisiting_user = User.find_by(username: name.gsub(" ", "_").downcase)
      if exisiting_user.present?
        n = 0
        loop do
          n = n + 1
          uniqname = name.gsub(" ", "_").downcase + n.to_s
          break if User.where(username: uniqname).exists? == false
        end
        update(username: name.gsub(" ", "_").downcase + n.to_s)
      else
        update(username: name.gsub(" ", "_").downcase)
      end
    end
  end

  def at_least_16
    if date_of_birth
      errors.add(:date_of_birth, "You must be 16 years or older.") if Time.now.to_date - date_of_birth.to_date < 5840
    end
  end

  def set_account_created
    User.find_by(email: email).update_attributes(account_created: true)
  end

  def send_welcome_email
    mailer = UserMailer.welcome_email(self)
    mailer.deliver_later
  end

  def user_profile_picture  
    self.fb_image ||= " "
    self.picture ||= " "
    self.bio ||= " "
  end

  protected

  def email_required?
    super && provider.blank?
  end
end
