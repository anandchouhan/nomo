class TripLocationsController < ApplicationController
  def index
    @trip_locations = current_user.upcoming_trip_locations

    # These colors are only used for the calendar
    @trip_locations.each_with_index do |trip_location, index|
      index -= TripLocation::COLORS.length if index > TripLocation::COLORS.length
      trip_location.color = TripLocation::COLORS[index]
    end
  end
  
  def show
    @trip_location = TripLocation.find_by_id(params[:id])

    if @trip_location.nil?
      redirect_to root_url, notice: "Location not found"
    else
      @trip = @trip_location.trip

      @overlapping_friends_participants = TripLocationParticipant.joins("INNER JOIN trip_locations ON trip_locations.id = trip_location_participants.trip_location_id").
        joins("INNER JOIN friendships ON friendships.destination_user_id = trip_location_participants.user_id").
        joins("INNER JOIN trips ON trips.id = trip_locations.trip_id").
        where("(trip_locations.start_at, trip_locations.end_at) OVERLAPS (?, ?) AND trip_locations.location_id = ? AND friendships.origin_user_id = ? AND trips.privacy_settings != 'JustMe' AND trip_locations.id != ?", @trip_location.start_at, @trip_location.end_at, @trip_location.location.id, current_user.id, @trip_location.id).
        distinct

      @overlapping_friends_currently_living = User.joins("INNER JOIN friendships ON friendships.destination_user_id = users.id").
        where("friendships.origin_user_id = ? AND users.location_id = ?", current_user.id, @trip_location.location.id).
        distinct
    end
  end

  def send_invitation
    trip_location = TripLocation.find(params[:id])
    sender = current_user
    recipient = User.find(params[:user_id])

    invitation = TripLocationInvitation.new(trip_location: trip_location, sender: sender, recipient: recipient)
    if invitation.save
      message = " invited you to the city "
      heading = "#{sender.name} #{message} <a href=#{trip_trip_location_path(trip_location.trip, trip_location)}>#{trip_location.location.name}</a>"
      mobile_url = trip_location.custom_email_html(trip_location.trip, message, "invite_trip")
      push_message = "#{sender.name} #{message} #{trip_location.location.name}"
      Notification.create(heading: heading, recipient: recipient, sender: sender, notify_type: "invite_trip", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_TRIP_INVITATIONS, context: mobile_url)
      if recipient.ios_device_token.present?  
        device_token = recipient.ios_device_token
        type = "ios"
      else
        device_token = recipient.android_device_token
        type = "android"
      end
      data = { notify_type: "invite_trip", sender_user_id: sender.id, recipient_user_id: recipient.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: sender.name, device_token: device_token, device_type: type, message: push_message }
      puts data
      Notification.send_push_notification(data) if device_token.present?
    end

    redirect_to trip_trip_location_path(trip_location.trip, trip_location)
  end

  def accept_invitation
    trip_location = TripLocation.find(params[:id])
    recipient = User.find(params[:user_id])

    invitation = TripLocationInvitation.where("trip_location_id = ? AND recipient_user_id = ?", trip_location.id, recipient.id)

    ActiveRecord::Base.transaction do
      TripLocationParticipant.create(trip_location: trip_location, user: recipient)
      invitation.destroy_all
    end

    redirect_to trip_trip_location_path(trip_location.trip, trip_location)
  end

  def send_request_to_join
    trip_location = TripLocation.find(params[:id])
    user = User.find(params[:user_id])

    request_to_join = RequestToJoin.new(trip_location: trip_location, user: user)
    if request_to_join.save
      message = " has requested to join the city "
      heading = "#{user.name} #{message} #{trip_location.location.name} of your trip <a href=#{trip_trip_location_path(trip_location.trip, trip_location)}>#{trip_location.trip.name}</a>"
      mobile_url = trip_location.custom_email_html(user, message, "join_trip")
      push_message = "#{current_user.name} #{message} #{trip_location.location.name} of your trip #{trip_location.trip.name}"
      Notification.create(heading: heading, recipient: trip_location.trip.user, sender: user, notify_type: "join_trip", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_TRIP_INVITATIONS, context: mobile_url)
      if trip_location.trip.user.ios_device_token.present?  
        device_token = trip_location.trip.user.ios_device_token
        type = "ios"
      else
        device_token = trip_location.trip.user.android_device_token
        type = "android"
      end
      data = { notify_type: "join_trip", sender_user_id: current_user.id, recipient_user_id: trip_location.trip.user.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
      Notification.send_push_notification(data) if device_token.present?
    end

    redirect_to trip_trip_location_path(trip_location.trip, trip_location)
  end

  def accept_request_to_join
    trip_location = TripLocation.find(params[:id])
    user = User.find(params[:user_id])

    request_to_join = RequestToJoin.where("trip_location_id = ? AND user_id = ?", trip_location.id, params[:user_id])

    ActiveRecord::Base.transaction do
      TripLocationParticipant.create(trip_location: trip_location, user: user)
      request_to_join.destroy_all
    end

    redirect_to trip_trip_location_path(trip_location.trip, trip_location)
  end

  def decline_invitation
    trip_location = TripLocation.find(params[:id])
    recipient = User.find(params[:user_id])
    TripLocationInvitation.where("trip_location_id = ? AND recipient_user_id = ?", trip_location.id, recipient.id).destroy_all
    redirect_to trip_trip_location_path(trip_location.trip, trip_location)
  end

  def remove_user
    trip_location = TripLocation.find(params[:id])
    trip_participant = TripLocationParticipant.where("trip_location_id = ? AND user_id = ?", trip_location.id, params[:user_id])
    trip_participant.destroy_all
    redirect_to trip_trip_location_path(trip_location.trip, trip_location)
  end

  def decline_request_to_join
    trip_location = TripLocation.find(params[:id])
    request_to_join = RequestToJoin.where("trip_location_id = ? AND user_id = ?", trip_location.id, params[:user_id])
    request_to_join.destroy_all
    redirect_to trip_trip_location_path(trip_location.trip, trip_location)
  end

  # Used when a marker representing a location in Google Maps is clicked.
  #   It retrieves trip locations for the user and his friends.
  def trip_locations_for_map 
    user_id = params[:user_id]
    location_id = params[:location_id]

    @location_name = Location.find(location_id).city_signature_or_formatted_address

    if params[:start_at].present? && params[:end_at].present?
      @start_at = Date.strptime(params[:start_at], "%m/%d/%Y").to_time(:utc).beginning_of_day
      @end_at = Date.strptime(params[:end_at], "%m/%d/%Y").to_time(:utc).end_of_day

      @user_trip_locations = TripLocation.joins("INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id").
        where("(trip_locations.start_at, trip_locations.end_at) OVERLAPS (?, ?) AND trip_location_participants.user_id = ? AND trip_locations.location_id = ?", @start_at, @end_at, user_id, location_id).
        distinct
    else
      @user_trip_locations = TripLocation.joins("INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id").
        where("trip_locations.end_at > ? AND trip_location_participants.user_id = ? AND trip_locations.location_id = ?", Time.zone.now, user_id, location_id).
        distinct
    end

    if params[:show_friend_locations] == "true"
      friends_trip_locations_sql = <<-SQL
        SELECT trip_locations.*
        FROM trip_locations
        INNER JOIN trip_location_participants ON trip_location_participants.trip_location_id = trip_locations.id
        INNER JOIN friendships ON friendships.destination_user_id = trip_location_participants.user_id
        INNER JOIN trips ON trips.id = trip_locations.trip_id
        WHERE (trip_locations.start_at, trip_locations.end_at) OVERLAPS (:start_at, :end_at)
        AND trip_locations.location_id = :location_id
        AND friendships.origin_user_id = :user_id
        AND trips.privacy_settings != 'JustMe'
      SQL
      @friends_trip_locations = TripLocation.find_by_sql [friends_trip_locations_sql, { start_at: @start_at, end_at: @end_at, location_id: location_id, user_id: user_id }]

      # Get friends whose current locations not overlaps with trips on those selected dates
      sql = <<-SQL
        SELECT users.*
        FROM users
        INNER JOIN friendships ON friendships.destination_user_id = users.id
        WHERE users.location_id = :location_id
        AND users.location_privacy IN (1, 2, 3)
        AND friendships.origin_user_id = :user_id

        EXCEPT

        SELECT users.*
        FROM users
        INNER JOIN trip_location_participants ON trip_location_participants.user_id = users.id
        INNER JOIN trip_locations ON trip_locations.trip_id = trip_location_participants.trip_location_id
        INNER JOIN friendships ON friendships.destination_user_id = trip_location_participants.user_id
        WHERE (trip_locations.start_at, trip_locations.end_at) OVERLAPS (:start_at, :end_at)
        AND friendships.origin_user_id = :user_id
      SQL
      @friends = User.find_by_sql [sql, { start_at: @start_at, end_at: @end_at, location_id: location_id, user_id: user_id }]
    else
      @friends_trip_locations = TripLocation.none
      @friends = User.none
    end
    
    render layout: false
  end
end
