class Api::TripLocationsController < Api::BaseController
  def trip_participants
    @data = []
    trip_location = TripLocation.where(id: params[:trip_location_id]).select(:id, :start_at, :end_at, :location_id, :trip_id).first
    participants = trip_location.try(:participants).select(:id, :name, :picture, :fb_image)
    @message = "Friends list those going in this trip."
    if participants.present?
      owner = trip_location.trip.user_id
      trip_location = trip_location.as_json.merge(start_at: trip_location["start_at"].strftime("%b %d, %Y"), end_at: trip_location["end_at"].strftime("%b %d, %Y"))
      trip_location.delete("trip_id")
      @data.push(trip_location: trip_location, owner_id: owner, participants: participants) 
      response_params_with_data
    else
      failed_response_params
    end
  end

  def remove_from_trip
    trip_location = TripLocation.find(params[:trip_location_id])
    if trip_location.present?
      TripLocationParticipant.find_by_trip_location_id_and_user_id(params[:trip_location_id], current_user.id).destroy
      @message = "You removed from the trip."
      success_response_params
    else
      @message = "Trip location is not present"
      failed_response_params
    end
  end

  def remove_participant_from_trip
    trip_location = TripLocation.find(params[:trip_location_id])
    trip_participant = TripLocationParticipant.where("trip_location_id = ? AND user_id = ?", trip_location.id, params[:user_id])
    trip_participant.destroy_all
    @message = "Participant removed from the trip."
    success_response_params
  end

  # def pending_requests_to_join_trip
  #   @data = []
  #   trip_location = TripLocation.find(params[:trip_location_id])
  #   @data = User.where("id in (?)", trip_location.requests_to_join.map(&:user_id)).select(:id, :name, :picture) if trip_location.try(:participants).map(&:id).include?(current_user.id)
  #   @message = "Pedning requests."
  #   response_params_with_data
  # end

  def pending_invite_trip_requests
    @data = []
    trip_location = TripLocation.find_by_id(params[:trip_location_id])
    invite_request = User.where("id in (?)", trip_location.trip_location_invitations.map(&:recipient_user_id)).select(:id, :name, :picture, :fb_image).map { |invite| invite.as_json.merge(is_invite: false) }
    join_request = User.where("id in (?)", trip_location.requests_to_join.map(&:user_id)).select(:id, :name, :picture, :fb_image).map { |join| join.as_json.merge(is_invite: true) }
    @message = "Pending requests."
    @data = (invite_request + join_request).flatten
    response_params_with_data
  end

  def decline_request_to_join_trip
    trip_location = TripLocation.find(params[:trip_location_id])
    request_to_join = RequestToJoin.where("trip_location_id = ? AND user_id = ?", trip_location.id, params[:user_id])
    request_to_join.destroy_all
    @message = "Join trip's request successfully deleted."
    success_response_params
  end

  def send_invite_request
    trip_location = TripLocation.find(params[:trip_location_id])
    sender = current_user
    recipient = User.find(params[:user_id])
    invitation = TripLocationInvitation.where("trip_location_id = ? AND recipient_user_id = ? AND sender_user_id = ?", trip_location.id, recipient.id, sender.id)
    if invitation.present?
      @message = "Already sent invitation"
      failed_response_params 
    else  
      invitation = TripLocationInvitation.new(trip_location: trip_location, sender: sender, recipient: recipient)
      if invitation.save
        message = " invited you to the city "
        heading = "<a href=#{user_path(sender)}>#{sender.name}</a>#{message}<a href=#{trip_trip_location_path(trip_location.trip, trip_location)}>#{trip_location.location.name}</a>"
        push_message = "#{sender.name}#{message}#{trip_location.location.name}"
        mobile_url = trip_location.custom_email_html(trip_location.trip, message, "invite_trip")
        Analytic.create_analytic(current_user.id, params[:device_type], nil, "invite_from_trip", params[:vs], params[:app_version], nil, nil)
        Notification.create(heading: heading, recipient: recipient, sender: sender, notify_type: "invite_trip", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_TRIP_INVITATIONS, context: mobile_url)
        if recipient.ios_device_token.present?  
          device_token = recipient.ios_device_token
          type = "ios"
        else
          device_token = recipient.android_device_token
          type = "android"
        end
        data = { notify_type: "invite_trip", sender_user_id: sender.id, recipient_user_id: recipient.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: sender.name, device_token: device_token, device_type: type, message: push_message }
        Notification.send_push_notification(data) if device_token.present?
      end
      @message = "Invitation sent successfully."
      success_response_params
    end
    send_friend_request_with_invitaion(recipient)
  end

  def send_friend_request_with_invitaion(user)
    friendship = Friendship.where("(origin_user_id = ? AND destination_user_id = ?) OR (origin_user_id = ? AND destination_user_id = ?)", current_user.id, params[:user_id], params[:user_id], current_user.id).first 
    friend_request = FriendRequest.where("(sender_user_id = ? AND recipient_user_id = ?) OR (sender_user_id = ? AND recipient_user_id = ?)", current_user.id, user.id, user.id, current_user.id).first
    if friend_request.nil? && friendship.nil?
      friend_request = FriendRequest.create(sender_user_id: current_user.id, recipient_user_id: user.id)
      message = "You you have new Friend Request from"
      heading = "#{message} <a href=#{user_path(current_user)}>#{current_user.name}</a>."
      mobile_url = friend_request.friend_request_custom_email_html(current_user, message, "send_friend_request")
      Notification.create(heading: heading, recipient: user, sender: current_user, notify_type: "send_friend_request", user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIEND_REQUESTS, context: mobile_url)
      push_message = "#{message} #{current_user.name}"
      if user.ios_device_token.present?  
        device_token = user.ios_device_token
        type = "ios"
      else
        device_token = user.android_device_token
        type = "android"
      end
      data = { notify_type: "send_friend_request", sender_user_id: current_user.id, recipient_user_id: user.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
      Notification.send_push_notification(data) if device_token.present?
    end
  end

  def accept_invite_request
    trip_location = TripLocation.find(params[:trip_location_id])
    user = User.find(params[:user_id])
    invitation = TripLocationInvitation.where("trip_location_id = ? AND recipient_user_id = ?", trip_location.id, current_user.id)
    ActiveRecord::Base.transaction do
      TripLocationParticipant.create(trip_location: trip_location, user: current_user)
      invitation.destroy_all
    end
    push_message = "#{current_user.name} accepted your request to the city #{trip_location.location.name}"
    if user.ios_device_token.present?  
      device_token = user.ios_device_token
      type = "ios"
    else
      device_token = user.android_device_token
      type = "android"
    end
    data = { notify_type: "invite_trip", sender_user_id: current_user.id, recipient_user_id: user.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
    Notification.send_push_notification(data) if device_token.present?
    @message = "Accepted invitation successfully."
    success_response_params
  end

  def reject_invite_request
    trip_location = TripLocation.find(params[:trip_location_id])
    recipient = User.find(params[:user_id])
    TripLocationInvitation.where("trip_location_id = ? AND recipient_user_id = ?", trip_location.id, recipient.id).destroy_all
    @message = "Rejected invitation successfully."
    success_response_params
  end

  def accept_requests_to_join_trip
    trip_location = TripLocation.find(params[:trip_location_id])
    user = User.find(params[:user_id])
    sender = current_user
    request_to_join = RequestToJoin.where("trip_location_id = ? AND user_id = ?", trip_location.id, params[:user_id])
    ActiveRecord::Base.transaction do
      TripLocationParticipant.create(trip_location: trip_location, user: user)
      request_to_join.destroy_all
      message = " has accepted your request to the city "
      heading = "<a href=#{user_path(sender)}>#{sender.name}</a>#{message}<a href=#{trip_trip_location_path(trip_location.trip, trip_location)}>#{trip_location.location.name}</a>"
      mobile_url = trip_location.custom_email_html(current_user, message, "accept_join_request")
      Notification.create(heading: heading, recipient: user, sender: sender, notify_type: "accept_join_request", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_TRIP_INVITATIONS, context: mobile_url)
      push_message = "#{sender.name}#{message}#{trip_location.location.name}"
      if user.ios_device_token.present?  
        device_token = user.ios_device_token
        type = "ios"
      else
        device_token = user.android_device_token
        type = "android"
      end
      data = { notify_type: "accept_join_request", sender_user_id: sender.id, recipient_user_id: user.id, trip_location_id: trip_location.id, trip_id: trip_location.trip.id, name: sender.name, device_token: device_token, device_type: type, message: push_message }
      Notification.send_push_notification(data) if device_token.present?
    end
    @message = "Request accepted."
    success_response_params
  end

  def trip_join_request
    trip_location = TripLocation.find(params[:trip_location_id])
    request_to_join = RequestToJoin.where(trip_location_id: trip_location.id, user_id: current_user.id)
    if !request_to_join.present?
      request_to_join = RequestToJoin.new(trip_location_id: trip_location.id, user_id: current_user.id)
      if request_to_join.save
        message = " has requested to join the city "
        heading = "<a href=#{user_path(current_user)}>#{current_user.name}</a>#{message}#{trip_location.location.name} of your trip <a href=#{trip_trip_location_path(trip_location.trip, trip_location)}>#{trip_location.trip.name}</a>"
        push_message = "#{current_user.name}#{message}#{trip_location.location.name} of your trip #{trip_location.trip.name}"
        mobile_url = trip_location.custom_email_html(current_user, message, "join_trip")
        Notification.create(heading: heading, recipient: trip_location.trip.user, sender: current_user, notify_type: "join_trip", trip_location_id: trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_TRIP_INVITATIONS, context: mobile_url)
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
      @message = "Request successfully sent."
    else
      @message = "Request already sent."
    end
    success_response_params
  end

  def trip_overlapping
    @data = []
    @trip_location = TripLocation.find_by_id(params[:trip_location_id])
    @overlapping_friends = TripLocationParticipant.joins("INNER JOIN trip_locations ON trip_locations.id = trip_location_participants.trip_location_id").
      joins("INNER JOIN friendships ON friendships.destination_user_id = trip_location_participants.user_id").
      joins("INNER JOIN trips ON trips.id = trip_locations.trip_id").
      where("(trip_locations.start_at, trip_locations.end_at) OVERLAPS (?, ?) AND trip_locations.location_id = ? AND friendships.origin_user_id = ? AND trips.privacy_settings != 'JustMe' AND trip_locations.id != ?", @trip_location.start_at, @trip_location.end_at, @trip_location.location.id, current_user.id, @trip_location.id).
      distinct
    @overlapping_friends = User.where("id in (?)", @overlapping_friends.map(&:user_id)).select(:id, :name, :picture, :fb_image)
    @overlapping_friends_currently_living = User.joins("INNER JOIN friendships ON friendships.destination_user_id = users.id").
      where("friendships.origin_user_id = ? AND users.location_id = ?", current_user.id, @trip_location.location.id).
      distinct
    @overlapping_friends_currently_living = @overlapping_friends_currently_living.select(:id, :name, :picture, :fb_image)
    @data.push(overlapping_friends: @overlapping_friends, overlapping_friends_living: @overlapping_friends_currently_living)
    @message = "Overlapping friends."
    response_params_with_data
  end

  def create_trip_comments
    @activity = TripLocation.find(params[:trip_location_id]).activity
    @comment = Comment.new(commentable_id: @activity.id, commentable_type: "Activity", body: params[:body], user_id: current_user.id)
    if @comment.save
      Analytic.create_analytic(current_user.id, params[:device_type], nil, "comment_created", params[:vs], params[:app_version], nil, nil)
      create_activity_notification
      @message = "Comment successfully created."
      success_response_params
    else
      @message = @comment.full_messages[0]
      failed_response_params
    end
  end

  def trip_location_chat
    @trip_location = TripLocation.find(params[:trip_location_id]).activity.trackable
    @comment = Comment.new(commentable_id: @trip_location.id, commentable_type: "TripLocation", body: params[:body], user_id: current_user.id)
    if @comment.save
      Analytic.create_analytic(current_user.id, params[:device_type], nil, "chat_comment_created", params[:vs], params[:app_version], nil, nil)
      create_trip_location_notification 
    end
  end

  def comment_list
    comments = Comment.where(commentable_id: params[:trip_location_id], commentable_type: "TripLocation").select(:id, :body, :user_id, :created_at, :commentable_id, :commentable_type).order("created_at ASC")
    @data = comments.map { |comment| comment.as_json.merge(body: comment.body.delete("\t\r\n").strip, user_name: comment.user.name, picture: comment.user.picture, fb_image: comment.user.picture) }
    @message = "Gruop chat list."
    response_params_with_data
  end
  
  # rubocop:disable Metrics/PerceivedComplexity
  def trip_lookup
    @data = []
    friend_ids = current_user.friends.map(&:id)
    month_start = Date.current.beginning_of_month
    month_end = month_start.end_of_month
    if params.include?("calendar")
      if params[:calendar].present?
        year_and_month = params[:calendar].split(",").map(&:to_i)
        year = year_and_month[0]
        month = year_and_month[1]
        month_start = Date.new(year, month) 
        month_end = month_start.end_of_month
      end
      locations = if params[:calendar].present?
                    TripLocation.joins(:trip).where("(end_at >= ? AND end_at <= ? AND trips.user_id = ?)", month_start, month_end, current_user.id).select(:id, :trip_id, :start_at, :end_at, :location_id)
                  else
                    TripLocation.joins(:trip).where("(start_at BETWEEN ? AND ? AND trips.user_id = ?) AND (end_at BETWEEN ? AND ? AND trips.user_id = ?) OR (end_at BETWEEN ? AND ? AND trips.user_id = ?)", month_start, month_end, current_user.id, month_start, month_end + 30.days, current_user.id, month_start, month_end, current_user.id).select(:id, :trip_id, :start_at, :end_at, :location_id)
                  end        
      @message = "Trip list according to month"
    elsif params.include?("map")
      user_location_lat_lng = params[:map].split(",")
      start_at = params[:start_at].to_date
      end_at = params[:end_at].to_date
      locations = if params[:start_at].present? && params[:end_at].present? && user_location_lat_lng.present?
                    # need to apply lat lng filter for a radius like 1000 meter or 1 KM
                    TripLocation.joins(:trip).where("(trips.privacy_settings = ? AND trips.user_id IN (?)) OR (trips.privacy_settings = ? AND trips.user_id IN (?)) OR (trips.privacy_settings = ? AND trips.user_id IN (?)) OR (trips.user_id = ?)", "MyNetwork", friend_ids, "FriendsOfFriends", friend_ids, "Public", friend_ids, current_user.id).where("(start_at <= ? AND end_at >= ?) OR (start_at = ? AND end_at = ?) OR (start_at >= ? AND end_at <= ?)", start_at, end_at, start_at, start_at, start_at, end_at).select(:id, :trip_id, :start_at, :end_at, :location_id)
                  else
                    TripLocation.joins(:trip).where("(trips.privacy_settings = ? AND trips.user_id IN (?)) OR (trips.privacy_settings = ? AND trips.user_id IN (?)) OR (trips.privacy_settings = ? AND trips.user_id IN (?)) OR (trips.user_id = ?)", "MyNetwork", friend_ids, "FriendsOfFriends", friend_ids, "Public", friend_ids, current_user.id).where("(start_at <= ? AND end_at >= ?) OR (start_at = ? AND end_at = ?) OR (start_at >= ? AND end_at <= ?)", Time.now.utc.to_date, Time.now.utc.to_date, Time.now.utc.to_date, Time.now.utc.to_date, Time.now.utc.to_date, Time.now.utc.to_date)
                  end 
      @message = "Trip list according to the date"
    end
    if params.include?("map")
      frndz_current_location = []
      friends_and_user = []
      friends_and_user << current_user.friends
      friends_and_user.flatten.uniq.each do |user_location|
        if user_location.location.present?
          user = { id: user_location.id, name: user_location.name, picture: user_location.picture, fb_image: user_location.fb_image }
          location = { latitute: user_location.location.lat.to_f, longitute: user_location.location.lng.to_f }
          frndz_current_location.push(is_no_trip: true, user: user, user_location: location)
        end
      end
    end                                
    @data = locations.map { |trip_location| trip_location.as_json.merge(name: trip_location.trip.name, start_at: trip_location.start_at.strftime("%b %d, %Y"), end_at: trip_location.end_at.strftime("%b %d, %Y"), location: trip_location.location.formatted_address, latitute: trip_location.location.lat.to_f, longitute: trip_location.location.lng.to_f, participants: trip_location.participants.count, is_no_trip: false, user: User.where(id: trip_location.trip.user_id).select(:id, :name, :picture, :fb_image)[0].as_json, trip_duration: (trip_location.start_at..trip_location.end_at).to_a) }
    if params.include?("map")  
      trip_participants = locations.map { |participant| participant.participants.map(&:id) }.flatten.uniq
      frndz_current_location = frndz_current_location.reject { |key| key if trip_participants.include?(key[:user][:id]) }.compact.uniq
      frndz_current_location.each do |frnd_object|
        @data.push(frnd_object)
      end
    end

    response_params_with_data
  end
  # rubocop:enable Metrics/PerceivedComplexity

  def trip_image
    trip_location = TripLocation.find(params[:trip_location_id])
    trip_location.images.create(user_id: current_user.id, image_path: params[:trip_image])
    Analytic.create_analytic(current_user.id, params[:device_type], nil, "photos_upload", params[:vs], params[:app_version], nil, nil)
    @message = "image upload successfully"
    success_response_params
  end

  def delete_trip_image
    delete_image
  end

  def report_trip_image
    delete_image
  end

  def delete_image
    image = Image.find_by_id(params[:image_id])
    image.destroy
    @message = "image removed successfully"
    success_response_params
  end

  private

  def success_response_params
    render json: {
      success: true,
      message: @message
    }
  end

  def failed_response_params
    render json: {
      success: false,
      message: @message
    }
  end

  def response_params_with_data
    render json: {
      success: true,
      message: @message,
      data: @data
    }
  end

  def create_trip_location_notification
    heading = "You have a new comment from #{@comment.user.name} on the city that you are attending to <a href=#{trip_trip_location_path(@trip_location.trip, @trip_location)}>#{@trip_location.location.name}</a>"
    mobile_url = @trip_location.trip_location_comment_custom_email_html(@comment, "trip_location_comment")
    push_message = "You have a new comment from #{@comment.user.name} on the city that you are attending to #{@trip_location.location.name}"
    @trip_location.participants.each do |user|
      unless current_user == user
        Notification.create(heading: heading, recipient_user_id: user.id, sender_user_id: @comment.user.id, notify_type: "trip_location_comment", trip_location_id: @trip_location.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_COMMENTS_ON_MY_ACTIVITY, context: mobile_url)
        if user.ios_device_token.present?  
          device_token = user.ios_device_token
          type = "ios"
        else
          device_token = user.android_device_token
          type = "android"
        end
        data = { notify_type: "trip_location_comment", sender_user_id: @comment.user.id, recipient_user_id: user.id, trip_location_id: @trip_location.id, trip_id: @trip_location.trip.id, name: @comment.user.name, device_token: device_token, device_type: type, message: push_message }
        Notification.send_push_notification(data) if device_token.present?
      end
    end
  end

  def create_activity_notification
    unless current_user == @activity.trackable.trip.user  
      heading = "You have a new comment from #{@comment.user.name} on the city that you are attending to <a href=#{activity_path(@comment.commentable)}>#{@activity.trackable.location.name}</a>"
      mobile_url = @activity.trackable.trip_location_activity_custom_email_html(@comment, "activity_comment")
      push_message = "You have a new comment from #{@comment.user.name} on the city that you are attending to #{@activity.trackable.location.name}"
      Notification.create(heading: heading, recipient_user_id: @activity.trackable.trip.user_id, sender_user_id: @comment.user_id, notify_type: "activity_comment", trip_location_id: @activity.trackable.id, user_setting_key: UserSetting::NOTIFICATION_EMAIL_COMMENTS_ON_MY_ACTIVITY, context: mobile_url) 
      if @activity.trackable.trip.user.ios_device_token.present?  
        device_token = @activity.trackable.trip.user.ios_device_token
        type = "ios"
      else
        device_token = @activity.trackable.trip.user.android_device_token
        type = "android"
      end
      data = { notify_type: "activity_comment", sender_user_id: @comment.user_id, recipient_user_id: @activity.trackable.trip.user_id, trip_location_id: @activity.trackable.id, trip_id: @activity.trackable.trip.id, name: @comment.user.name, device_token: device_token, device_type: type, message: push_message }
      Notification.send_push_notification(data) if device_token.present?
    end
  end
end