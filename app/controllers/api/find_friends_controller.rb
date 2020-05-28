class Api::FindFriendsController < Api::BaseController
  def my_friends
    @my_friends = current_user.friends.select(:id, :email, :name, :picture, :fb_image)
    unless params[:trip_location_id] == "0"
      trip_location = TripLocation.find_by_id(params[:trip_location_id])
      @my_friends = @my_friends - [trip_location.trip_location_invitations.map(&:recipient).push(trip_location.participants)].flatten - [current_user]
    end
    if @my_friends.present?
      render json: {
        success: true,
        message: "Get friends list",
        data: @my_friends 
      }
    else
      render json: {
        success: true,
        message: "No friends found",
        data: @my_friends 
      }
    end
  end

  def facebook_friends
    if current_user.oauth_expires_at.present? && current_user.oauth_expires_at >= Time.now.utc
      @friends = []
      sent_friend_request_ids = current_user.sent_friend_requests.map(&:recipient_user_id)
      friend_ids = current_user.friends.map(&:id)
      facebook_friend_ids = current_user.fb_freinds.map(&:id)
      facebook_friends = User.where("id in (?)", facebook_friend_ids).order("created_at ASC").select("id, email, name, picture, fb_image").compact.uniq - [current_user]
      facebook_friends.as_json.each do |fb| 
        fb["fb_image"] = "" if fb["fb_image"].blank?
        if sent_friend_request_ids.include?(fb["id"]) 
          @friends.push(fb.merge(status: "pending"))
        elsif !sent_friend_request_ids.include?(fb["id"]) && !friend_ids.include?(fb["id"])
          @friends.push(fb.merge(status: "requested"))
        else
          @friends.push(fb.merge(status: "friend"))
        end
      end
    else
      date_expired = true
    end
    if date_expired
      render json: {
        success: true,
        message: "Date is expired",
        is_oauth_expired: true, 
        data: []
      }
    else 
      render json: {
        success: true,
        message: "Get friends list",
        is_oauth_expired: false,
        data: @friends.compact
      }
    end
  end

  def send_friend_request
    user = User.where(" id = ? OR uid = ?", params[:user_id], params[:facebook_id]).first
    if user.present?
      sender_user_id = current_user.id
      recipient_user_id = user.id

      # Friend request does exist when the sender user has sent the invite,
      # and the recipient has not reloaded the page.
      friend_request = FriendRequest.where("(sender_user_id = ? AND recipient_user_id = ?) OR (sender_user_id = ? AND recipient_user_id = ?)", sender_user_id, recipient_user_id, recipient_user_id, sender_user_id).first
      if friend_request.nil?
        friend_request = FriendRequest.create(sender_user_id: sender_user_id, recipient_user_id: recipient_user_id)
        message = "New Friend Request from "
        heading = "#{message} <a href=#{user_path(current_user)}>#{current_user.name}</a>."
        mobile_url = friend_request.friend_request_custom_email_html(current_user, message, "send_friend_request")
        Notification.create(heading: heading, recipient: friend_request.recipient, sender: current_user, notify_type: "send_friend_request", user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIEND_REQUESTS, context: mobile_url)
        push_message = "#{message} #{current_user.name}"
        if user.ios_device_token.present?  
          device_token = user.ios_device_token
          type = "ios"
        else
          device_token = user.android_device_token
          type = "android"
        end
        data = { notify_type: "send_friend_request", sender_user_id: sender_user_id, recipient_user_id: friend_request.recipient.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message, trip_location_id: 0, trip_id: 0 }
        Notification.send_push_notification(data) if device_token.present?
      end
      render json: {
        success: true,
        message: "Friend request was sent successfully"
      }
    else
      render json: {
        success: false,
        message: "Friend not found or Invalid facebook id"
      }
    end
  end

  def accept_friend_request
    friend_request = FriendRequest.where("(sender_user_id = ? AND recipient_user_id = ?) OR (sender_user_id = ? AND recipient_user_id = ?)", current_user.id, params[:user_id], params[:user_id], current_user.id).first
    # Friend request does not exist when the sender user has canceled the invite,
    # and the recipient has not reloaded the page.
    if friend_request
      friend_request.accept
      message = " has accepted your Friend Request."
      heading = "<a href=#{user_path(friend_request.recipient)}>#{friend_request.recipient.name}</a>#{message}"
      mobile_url = friend_request.friend_request_custom_email_html(friend_request.recipient, message, "accept_friend_request")
      Notification.create(heading: heading, recipient: friend_request.sender, sender: friend_request.recipient, notify_type: "accept_friend_request", user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIEND_REQUESTS, context: mobile_url)
      push_message = "#{friend_request.recipient.name}#{message}"
      if friend_request.sender.ios_device_token.present?  
        device_token = friend_request.sender.ios_device_token
        type = "ios"
      else
        device_token = friend_request.sender.android_device_token
        type = "android"
      end
      data = { notify_type: "accept_friend_request", sender_user_id: friend_request.recipient.id, recipient_user_id: friend_request.sender.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
      Notification.send_push_notification(data) if device_token.present?
      render json: {
        success: true,
        message: "Friend request was accepted successfully"
      }
    else
      render json: {
        success: false,
        message: "Friend request not accepted successfully"
      }
    end
  end

  def destroy
    friendship = Friendship.where("(origin_user_id = ? AND destination_user_id = ?) OR (origin_user_id = ? AND destination_user_id = ?)", current_user.id, params[:user_id], params[:user_id], current_user.id) 
    if friendship.present? 
      friendship.destroy_all
      message = "Unfriend successfully"
    else
      FriendRequest.where("(sender_user_id = ? AND recipient_user_id = ?) OR (sender_user_id = ? AND recipient_user_id = ?)", current_user.id, params[:user_id], params[:user_id], current_user.id).destroy_all
      message = "Remove friend request successfully"
    end
    render json: {
      success: true,
      message: message
    }
  end

  def search_friends
    if params[:search].present?
      sent_friend_ids = current_user.sent_friend_requests.map(&:recipient_user_id)
      friends = current_user.friends
      search_params = params[:search].split.map(&:capitalize).join(" ") 
      friends = User.where("name LIKE ?", "%#{search_params}%").select(:id, :name, :picture, :fb_image, :uid, :signup_source) - [current_user].push(friends).flatten
      frnd_request = {}
      friend_lists = friends.map { |object| frnd_request.merge(id: object.id, name: object.name, picture: object.picture, fb_image: object.fb_image, status: sent_friend_ids.include?(object.id) ? "pending" : "requested", sign_from: object.signup_source == "facebook" ? "Facebook Friend" : "Nomo FOMO") }
      render json: {
        success: true,
        message: "Friend list",
        data: friend_lists
      }
    end
  end
end