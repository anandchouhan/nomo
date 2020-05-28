class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show index]

  def index
    if user_signed_in?
      redirect_to root_path
    else
      redirect_to root_path(referred_by: params[:referrer_id])
    end
  end

  def show
    @user = User.find_by_id(params[:id])
    if @user.nil?
      @user = User.where(username: params[:id]).take

      if @user.present?
        user_id = @user.id
        @user_locations = Location.joins("INNER JOIN trip_locations ON trip_locations.location_id = locations.id").
          joins("INNER JOIN trips ON trips.id = trip_locations.trip_id").
          joins("INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id").
          where("trip_location_participants.user_id = ?", user_id).distinct  

        if current_user == @user && @user.location
          @friends_visiting = TripLocationParticipant.joins("INNER JOIN trip_locations ON trip_locations.id = trip_location_participants.trip_location_id").
            joins("INNER JOIN friendships ON friendships.destination_user_id = trip_location_participants.user_id").
            where("friendships.origin_user_id = ? AND trip_locations.location_id = ?", @user.id, @user.location.id).
            distinct

          @friends_living = User.joins("INNER JOIN friendships ON friendships.destination_user_id = users.id").
            where("friendships.origin_user_id = ? AND users.location_id = ?", @user.id, @user.location.id).
            distinct
        else
          @friends_visiting = TripLocationParticipant.none
          @friends_living = User.none
        end
      else
        flash[:error] = "User not found"
        redirect_to root_url
      end
    else
      redirect_to "/users/#{@user.username}"
    end
  end

  def new
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    @user = User.new(user_params)
    @user.email.downcase!
    @user.location_privacy = User.location_privacies[:global]

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    old_username = @user.username
    
    @user.assign_attributes(user_params)
    @user.location_privacy = params[:user][:location_privacy].to_i

    if @user.save
      redirect_to "/users/" + @user.username, notice: "User was successfully updated."
    else
      redirect_to "/users/" + old_username, notice: @user.errors.full_messages.first
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def explorer
    @start_at = nil
    @end_at = nil

    if params[:start_at].present? && params[:end_at].present?
      # Explorer using dates filter
      @start_at = Date.strptime(params[:start_at], "%m/%d/%Y").to_time(:utc).beginning_of_day
      @end_at = Date.strptime(params[:end_at], "%m/%d/%Y").to_time(:utc).end_of_day
    else
      # Explorer not using dates filter
      @start_at = Time.zone.now.beginning_of_day
      @end_at = Time.zone.now.end_of_day
    end

    # Trip locations overrides current locations.
    # If a user's friends has a current location and a trip on those selected dates,
    # the trip has a higuer priority and the current location isn't shown.
    # Private trips don't count.
    # This query should be improved, this is the first version.
    friends_locations_sql = <<-SQL
      SELECT locations.*
      FROM locations
      INNER JOIN trip_locations ON trip_locations.location_id = locations.id
      INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id
      INNER JOIN friendships ON friendships.destination_user_id = trip_location_participants.user_id
      INNER JOIN trips ON trips.id = trip_locations.trip_id
      WHERE (trip_locations.start_at, trip_locations.end_at) OVERLAPS (:start_at, :end_at)
      AND trips.privacy_settings != 'JustMe'
      AND friendships.origin_user_id = :user_id

      UNION

      SELECT locations.*
      FROM locations
      INNER JOIN users ON users.location_id = locations.id
      INNER JOIN friendships ON friendships.destination_user_id = users.id
      WHERE friendships.origin_user_id = :user_id
      AND users.location_privacy IN (1, 2, 3)
      AND users.id IN (
        SELECT friendships.destination_user_id
        FROM friendships
        WHERE friendships.origin_user_id = :user_id

        EXCEPT

        SELECT friendships.destination_user_id
        FROM friendships
        INNER JOIN trip_location_participants ON trip_location_participants.user_id = friendships.destination_user_id
        INNER JOIN trip_locations ON trip_locations.id = trip_location_participants.trip_location_id
        WHERE (trip_locations.start_at, trip_locations.end_at) OVERLAPS (:start_at, :end_at)
        AND friendships.origin_user_id = :user_id
      )
    SQL
    friends_locations = Location.find_by_sql [friends_locations_sql, { user_id: current_user.id, start_at: @start_at, end_at: @end_at }]

    user_locations_sql = <<-SQL
      SELECT locations.*
      FROM locations
      INNER JOIN trip_locations ON trip_locations.location_id = locations.id
      INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id
      WHERE trip_location_participants.user_id = :user_id AND (trip_locations.start_at, trip_locations.end_at) OVERLAPS (:start_at, :end_at)
    SQL
    user_locations = Location.find_by_sql [user_locations_sql, { user_id: current_user.id, start_at: @start_at, end_at: @end_at }]

    friends_locations_hash = Hash.new
    friends_locations.each do |location|
      friends_locations_hash[location.id] = location
    end

    user_locations_hash = Hash.new
    user_locations.each do |location|
      user_locations_hash[location.id] = location
    end

    @friends_locations = Array.new
    @user_locations = Array.new
    @user_and_friends_locations = Array.new

    friends_locations_hash.each_pair do |location_id, location|
      if user_locations_hash[location_id]
        @user_and_friends_locations << location
        user_locations_hash.delete(location_id)
      else
        @friends_locations << location
      end
    end

    user_locations_hash.each do |location|
      @user_locations << location
    end
  end

  # Used when the user is searching a user in the Find Friends modal
  def lookup
    search = params[:search]
    @users = User.lookup(search)
    render layout: false
  end

  # Removes the friendship relationship between two users
  def unfriend
    @friend_id = User.find(params[:user_id]).id
    User.unfriend(current_user.id, @friend_id)

    respond_to do |format|
      format.js
      format.html { redirect_back fallback_location: root_path, notice: "Friendship was removed successfully" }
    end
  end

  def unlink
    current_user.unlink(params[:provider])
    redirect_to(:back)
  end

  def search_connected_friends
    @prov = params[:provider]
    if params[:provider] == "facebook" && current_user.valid_token?("facebook")
      @friends = current_user.fb_friends
    elsif params[:provider] == "linkedin" && current_user.valid_token?("linkedin")
      @friends = current_user.google_friends
    elsif params[:provider] == "google"
      current_user.check_google_token
      @friends = current_user.google_friends
    else
      @friends = nil
    end
    respond_to do |format|
      format.js
    end
  end

  private

  def user_params
    params.require(:user).permit(:username,
                                 :name,
                                 :email,
                                 :encrypted_password,
                                 :salt,
                                 :provider,
                                 :uid,
                                 :oauth_token,
                                 :oauth_expires_at,
                                 :role,
                                 :hometown_id,
                                 :location_id,
                                 :phone_number,
                                 :website,
                                 :bio,
                                 :twitter_id,
                                 :facebook_id,
                                 :instagram_id,
                                 :linked_in_id,
                                 :youtube_id,
                                 :blog_id)
  end
end
