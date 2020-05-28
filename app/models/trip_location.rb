class TripLocation < ApplicationRecord
  belongs_to :trip, inverse_of: :trip_locations
  validates_presence_of :trip
  
  belongs_to :location

  has_one :activity, as: :trackable, dependent: :destroy

  has_many :trip_location_participants, dependent: :destroy, inverse_of: :trip_location
  has_many :participants, through: :trip_location_participants, source: :user

  has_many :trip_location_invitations, dependent: :destroy, inverse_of: :trip_location
  has_many :requests_to_join, dependent: :destroy, inverse_of: :trip_location

  has_many :accommodations, dependent: :destroy, inverse_of: :trip_location
  has_many :travels, dependent: :destroy, inverse_of: :trip_location
  has_many :events, dependent: :destroy, inverse_of: :trip_location
  has_many :comments, as: :commentable, dependent: :destroy
  has_one :activity, as: :trackable, dependent: :destroy
  has_many :images, dependent: :destroy
  # Used for the admin
  accepts_nested_attributes_for :accommodations, allow_destroy: true
  accepts_nested_attributes_for :travels, allow_destroy: true
  accepts_nested_attributes_for :events, allow_destroy: true
  
  validates :location, presence: true
  validate :valid_dates

  before_create :build_activity
  before_create :add_owner_to_participants

  COLORS = %w(#35a2da #fa5f43 #21ccc7 #939090 #8c6ce7).freeze
  attr_accessor :color

  def friends_to_invite(user)
    pending_users = trip_location_invitations.map { |p| [p.sender_user_id, p.recipient_user_id] }.flatten.uniq
    uninvited_friends = pending_users + participants.map(&:id)
    user.friends.where.not(id: uninvited_friends)
  end

  def participant?(user)
    trip_location_participants.where(user_id: user.id).any?
  end

  # Used to decide which sections must be shown to the used passed as a parameter
  def can_see?(user)
    if trip.user == user
      true
    else
      participant?(user)
    end
  end

  def invited?(user)
    trip_location_invitations.where(recipient_user_id: user.id).any?
  end

  def friends_participating(user)
    User.joins("INNER JOIN trip_location_participants ON trip_location_participants.user_id = users.id").
      joins("INNER JOIN friendships ON friendships.destination_user_id = trip_location_participants.user_id").
      where("friendships.origin_user_id = ? AND trip_location_participants.trip_location_id = ?", user.id, id)
  end

  def trip_location_comment_custom_email_html(params, type)
    web_url_user = "users/#{params.user_id}"
    web_url_trip = "trips/#{trip_id}/locations/#{id}"
    m_url_user = "nomo-fomo:/#{web_url_user}&notify_type=user_detail"
    m_url_trip = "nomo-fomo:/#{web_url_trip}&notify_type=#{type}"
    mobile_url = "You have a new comment from"
    mobile_url = "#{mobile_url} <a href=/mobile_notification?user_id=#{params.user_id}&web_url=#{web_url_user}&mobile_url=#{m_url_user}>#{params.user.name}</a> on the city that you are attending to"
    mobile_url = "#{mobile_url} <a href=/mobile_notification?user_id=#{params.user_id}&trip_location_id=#{id}&web_url=#{web_url_trip}&mobile_url=#{m_url_trip}>#{location.name}</a>"
    mobile_url
  end

  def trip_location_activity_custom_email_html(params, type)
    web_url_user = "users/#{params.user_id}"
    web_url_trip = "trips/#{trip_id}/locations/#{id}"
    m_url_user = "nomo-fomo:/#{web_url_user}&notify_type=user_detail"
    m_url_trip = "nomo-fomo:/#{web_url_trip}&notify_type=#{type}"
    mobile_url = "You have a new comment from"
    mobile_url = "#{mobile_url} <a href=/mobile_notification?user_id=#{params.user_id}&web_url=#{web_url_user}&mobile_url=#{m_url_user}>#{params.user.name}</a> on the trip that you are attending to"
    mobile_url = "#{mobile_url} <a href=/mobile_notification?user_id=#{params.user_id}&trip_location_id=#{id}&web_url=#{web_url_trip}&mobile_url=#{m_url_trip}>#{location.name}</a>"
    mobile_url
  end

  def custom_email_html(params, message, type)
    if ["join_trip", "accept_join_request"].include?(type)
      web_url_user = "users/#{params.id}"
      web_url_trip = "trips/#{trip_id}/locations/#{id}"
      m_url_user = "nomo-fomo:/#{web_url_user}&notify_type=user_detail"
      m_url_trip = "nomo-fomo:/#{web_url_trip}&notify_type=#{type}"
      mobile_url = "<a href=/mobile_notification?user_id=#{params.id}&web_url=#{web_url_user}&mobile_url=#{m_url_user}>#{params.name}</a>"
      mobile_url = "#{mobile_url} #{message}"
      mobile_url = "#{mobile_url} <a href=/mobile_notification?user_id=#{params.id}&trip_location_id=#{id}&web_url=#{web_url_trip}&mobile_url=#{m_url_trip}>#{location.name}</a>"
    else
      web_url_user = "users/#{params.user_id}"
      web_url_trip = "trips/#{trip_id}/locations/#{id}"
      m_url_user = "nomo-fomo:/#{web_url_user}&notify_type=user_detail"
      m_url_trip = "nomo-fomo:/#{web_url_trip}&notify_type=#{type}"
      mobile_url = "<a href=/mobile_notification?user_id=#{params.user_id}&web_url=#{web_url_user}&mobile_url=#{m_url_user}>#{params.user.name}</a>"
      mobile_url = "#{mobile_url} #{message}"
      mobile_url = "#{mobile_url} <a href=/mobile_notification?user_id=#{params.user_id}&trip_location_id=#{id}&web_url=#{web_url_trip}&mobile_url=#{m_url_trip}>#{location.name}</a>" 
    end
    mobile_url
  end

  private

  def valid_dates
    if start_at.blank?
      errors.add(:start_at, "must not be empty")
    elsif end_at.blank?
      errors.add(:end_at, "must not be empty")
    elsif start_at > end_at
      errors.add(:end_at, "must be greater or equal than start date")
    end
  end

  def add_owner_to_participants
    trip_location_participant = TripLocationParticipant.new(trip_location: self, user: trip.user)
    trip_location_participants << trip_location_participant
  end
end
