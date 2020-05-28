class Api::UsersController < Api::BaseController
  def default_settings_data
    @default_settings = DefaultSetting.select(:title, :description).as_json(except: :id)
    render json: {
      success: true,
      message: "Get app setting successfully",
      data: { "homeText": @default_settings }
    }
  end

  def user_detail
    @user = current_user
    if @user.present?
      @google_place_id = @user.location.try(:google_place_id)
      @message = "User Get Successfully"
      update_api_token
    else
      render json: {
        success: false,
        message: "Invalid Token",
        data: {} 
      }
    end
  end

  def user_trips
    user = User.where(id: params[:user_id]).select(:id, :name, :picture, :fb_image, :bio, :location_id).first
    @data = []
    if user.present?
      friends_of_friends_ids = current_user.friends.map { |frnd| frnd.friends.map(&:id) }.flatten.compact.uniq
      friend_ids = current_user.friends.map(&:id)
      trip_locations = TripLocation.joins(:trip).where("trips.user_id = ?", user.id).where("trips.privacy_settings = ? OR (trips.privacy_settings = ? AND trips.user_id = ?) OR (trips.privacy_settings = ? AND trips.user_id IN (?)) OR (trips.privacy_settings = ? AND trips.user_id IN (?)) OR trips.user_id = ?", "Public", "JustMe", current_user.id, "MyNetwork", friend_ids, "FriendsOfFriends", (friends_of_friends_ids + friend_ids).uniq, current_user.id).select(:id, :location_id, :start_at, :end_at, :trip_id)
      trip_locations = trip_locations.map { |obj| obj.as_json.merge(start_at: obj["start_at"].strftime("%b %d, %Y"), end_at: obj["end_at"].strftime("%b %d, %Y"), city: obj.location.name, trip_id: obj.trip_id).except("location_id") }
      current_user_friend_ids = current_user.friends.map(&:id)
      user_friends = user.friends.select(:id, :name, :picture, :fb_image) - [current_user]
      friend_of_friends = []
      user_friends.each do |is_friend|
        is_friend_hash = if current_user_friend_ids.include?(is_friend.id)
                           is_friend.as_json.merge(status: "friend")
                         elsif FriendRequest.where("(sender_user_id = ? AND recipient_user_id = ?) OR (sender_user_id = ? AND recipient_user_id = ?)", current_user.id, is_friend.id, is_friend.id, current_user.id).exists?
                           is_friend.as_json.merge(status: "pending")
                         else
                           is_friend.as_json.merge(status: "requested")
                         end 
        friend_of_friends.push(is_friend_hash) 
      end 
      user_info = user.as_json.merge(city: user.location_id.present? ? user.location.try(:name) : " ").except("location_id")
      user_info["status"] = if current_user_friend_ids.include?(user.id)
                              "friend"
                            elsif FriendRequest.where("(sender_user_id = ? AND recipient_user_id = ?) OR (sender_user_id = ? AND recipient_user_id = ?)", current_user.id, params[:user_id], params[:user_id], current_user.id).exists?
                              "pending"
                            else
                              "requested"
                            end  
      render json: {
        success: true,
        message: "trips and friends detail",
        data: @data.push(user: user_info, trip_location: trip_locations, friend: friend_of_friends) 
      }
    else
      render json: {
        success: false,
        message: "trips and friends detail",
        data: @data
      }
    end
  end
  
  # rubocop:disable Metrics/PerceivedComplexity
  def user_notifications
    @data = []
    # join_requests = RequestToJoin.all
    # invite_requests = TripLocationInvitation.all
    # sender_ids = join_requests.map(&:user_id) + invite_requests.map(&:sender_user_id)
    # trip_location_ids = join_requests.map(&:trip_location_id) + invite_requests.map(&:trip_location_id)
    notifications = Notification.where(recipient_user_id: current_user.id).where.not("notify_type in (?)", ["accept_join_request", "accept_friend_request"]).select(:id, :is_read, :heading, :sender_user_id, :created_at, :notify_type, :trip_location_id, :recipient_user_id).order("created_at DESC")
    if params[:search].present? 
      search_params = params[:search].split.map(&:capitalize).join(" ")
      user_ids = User.where("name LIKE ?", "%#{search_params}%").map(&:id)
      city_ids = Location.where("name LIKE ?", "%#{search_params}%").map(&:id)
      trip_location_ids = TripLocation.where("location_id in (?)", city_ids).map(&:id)
      notifications = notifications.where("trip_location_id in (?) OR sender_user_id in (?)", trip_location_ids, user_ids)
    end 
    notification_types = ["like", "new_event", "new_travel", "new_accommodation", "like", "trip_location_comment", "activity_comment", "currently_living_in_city", "currently_living_in_city", "overlapping_trip", "friend_living_in_city", "i_living_in_city"]   
    notifications.each do |notification| 
      trip_location = TripLocation.find_by_id(notification.trip_location_id)
      next unless notification.sender.present?
      if (trip_location.present? && trip_location.try(:location_id).present?) || (notification.notify_type == "send_friend_request" && FriendRequest.find_by_recipient_user_id(notification.recipient_user_id).present?) || notification_types.include?(notification.notify_type) && (trip_location.present? && trip_location.try(:location_id).present?)
        heading = case notification.notify_type
                  when "invite_trip"
                    "invite you to their trip to <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b>"
                  when "join_trip"
                    "wants to join your trip to <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b>"
                  when "accept_join_request" 
                    "accept your request to the city <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b>"
                  when "new_event"
                    "created a new event on <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b>"
                  when "new_travel"
                    "created a new travel on <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b>"
                  when "new_accommodation"
                    "created a new accommodation on <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b>"        
                  when "send_friend_request"
                    "has sent a Friend Request"
                  when "accept_friend_request"
                    "has accepted your Friend Request"
                  when "like"
                    "liked your trip to <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b>"
                  when "trip_location_comment"
                    "<span style='font-family: sans-serif; font-size: 14px; color:#323B45;'>You have a new comment from <b>#{notification.sender.name}</b> on the trip that you are attending to <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b></span>" 
                  when "activity_comment"
                    "<span style='font-family: sans-serif; font-size: 14px; color:#323B45;'>You have a new comment from <b>#{notification.sender.name}</b> on the trip that you are attending to <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b></span>" 
                  when "currently_living_in_city"
                    "is going to your current location in the trip <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b>"
                  when "friend_living_in_city"
                    "<span style='font-family: sans-serif; font-size: 14px; color:#323B45;'>During your trip to <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b> you will be in the same city as <b>#{notification.sender.name}</b></span>"
                  when "i_living_in_city"
                    "is going to be in your current location of <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} to #{trip_location.end_at.strftime('%b %d, %Y')}</b>"
                  when "overlapping_trip"
                    "<span style='font-family: sans-serif; font-size: 14px; color:#323B45;'>During your trip to <b style='color:#E26849;'>#{trip_location.location.name}</b> from <b style='color:#E26849;'>#{trip_location.start_at.strftime('%b %d, %Y')} - #{trip_location.end_at.strftime('%b %d, %Y')}</b> you will be in the same city as <b>#{notification.sender.name}</b></span>"
                  end  
        unless notification.notify_type == "activity_comment" || notification.notify_type == "trip_location_comment" || notification.notify_type == "overlapping_trip" || notification.notify_type == "friend_living_in_city"        
          heading = "<span style='font-family: sans-serif; font-size: 14px; color:#323B45;'><b>#{notification.sender.name}</b> #{heading}</span>" 
        end
        @data.push(notification.as_json.merge(heading: heading, name: notification.sender.name, picture: notification.sender.picture, fb_image: notification.sender.fb_image)) 
      end
    end

    render json: {
      success: true,
      message: "Your notifications",
      data: @data
    }
  end
  # rubocop:enable Metrics/PerceivedComplexity

  def update_device_token
    user = current_user
    if params[:type] == "ios"
      user.update_attribute(:ios_device_token, params[:token])
    elsif params[:type] == "android"
      user.update_attribute(:android_device_token, params[:token])
    end
    render json: {
      success: true,
      message: "Token updated successfully"
    }
  end

  def enable_email_notification
    if params[:value] == "on"
      UserSetting.where(user_id: current_user.id).update_all(value: params[:value])
      analytic = Analytic.where("user_id = ? AND analytic_type = ?", current_user.id, "push_notification_permission").first
      unless analytic.present?
        analytic = Analytic.create_analytic(current_user.id, params[:device_type], nil, "push_notification_permission", params[:vs], params[:app_version], nil, nil)
      end
      analytic.update_attribute(:is_active, true)
      render json: {
        success: true,
        message: "Enable email notifications successfully"
      }
    elsif params[:value] == "off"
      UserSetting.where(user_id: current_user.id).update_all(value: params[:value])
      analytic = Analytic.where("user_id = ? AND analytic_type = ?", current_user.id, "push_notification_permission").first
      if analytic.present?
        analytic.update_attribute(:is_active, false)
      end
      render json: {
        success: true,
        message: "Disable email notifications successfully"
      }
    end
  end

  def analytics_auth
    user_id = current_user.id
    if params[:analytic_type] == "real_time_user"
      analytic = Analytic.where("user_id = ? AND device_type = ? AND device_token = ? AND analytic_type = ? AND created_at > ?", user_id, params[:device_type], params[:device_token], params[:analytic_type], Time.now.getutc.beginning_of_day).first
      if analytic.present?
        analytic.update_attribute(:is_active, params[:is_active])
        @message = "Analytic updated successfully."
      else
        Analytic.create_analytic(user_id, params[:device_type], params[:device_token], params[:analytic_type], params[:vs], params[:app_version], params[:start_time], params[:end_time])
        @message = "Analytic successfully saved."
      end
    elsif params[:analytic_type] == "average_time"
      analytic = Analytic.where("user_id = ? AND device_type = ? AND device_token = ? AND analytic_type = ? AND start_time = ?", user_id, params[:device_type], params[:device_token], params[:analytic_type], params[:start_time]).first
      if analytic.present? && params[:end_time].present?
        time_difference = params[:end_time] - analytic.start_time
        analytic.update_attributes(end_time: params[:end_time], time_difference: time_difference)
        @message = "Analytic updated successfully."
      else
        Analytic.create_analytic(user_id, params[:device_type], params[:device_token], params[:analytic_type], params[:vs], params[:app_version], params[:start_time], params[:end_time])
        @message = "Analytic successfully saved."
      end
    else
      analytic = Analytic.create_analytic(user_id, params[:device_type], params[:device_token], params[:analytic_type], params[:vs], params[:app_version], params[:start_time], params[:end_time])
      @message = "Analytic successfully saved."
      if analytic.analytic_type == "trip_create_signup"
        analytic.update_attributes(metric_classification: params[:trip_type], metric_identifier: params[:trip_id])
      end
    end 
    success_response_params
  end

  def mobile_notification_count
    if params[:is_read]
      notifications = current_user.notifications
      notifications.update_all(is_read: params[:is_read])
      render json: {
        success: true,
        count: 0
      }
    else
      notifications = current_user.notifications.where(is_read: params[:is_read]).count
      render json: {
        success: true,
        count: notifications
      }
    end
  end

  private

  def success_response_params
    render json: {
      success: true,
      message: @message
    }
  end
end

