class FriendRequestsController < ApplicationController
  def index
    @received_friend_requests = current_user.friend_requests
    @sent_friend_requests = current_user.sent_friend_requests
    @fb_friends = current_user.fb_freinds
    @friends = current_user.friends.order(:name)
    @waitlist = Waitlist.where("email = ?", current_user.email)
    @waitlist_id = @waitlist.present? ? @waitlist.take.id : nil
  end

  def create
    sender_user_id = current_user.id
    recipient_user_id = params[:recipient_user_id]
    message = "New Friend Request from "
    # Friend request does exist when the sender user has sent the invite,
    # and the recipient has not reloaded the page.
    friend_request = FriendRequest.where("(sender_user_id = :sender_user_id AND recipient_user_id = :recipient_user_id) OR (sender_user_id = :recipient_user_id AND recipient_user_id = :sender_user_id)", sender_user_id: sender_user_id, recipient_user_id: recipient_user_id).take
    if friend_request.nil?
      @friend_request = FriendRequest.create(sender_user_id: sender_user_id, recipient_user_id: recipient_user_id)
      heading = "#{message} <a href=#{user_path(current_user)}>#{current_user.name}"
      mobile_url = @friend_request.friend_request_custom_email_html(current_user, message, "send_friend_request")
      push_message = "#{message} #{current_user.name}"
      Notification.create(heading: heading, recipient: @friend_request.recipient, sender: current_user, notify_type: "send_friend_request", user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIEND_REQUESTS, context: mobile_url)
      if @friend_request.recipient.ios_device_token.present?  
        device_token = @friend_request.recipient.ios_device_token
        type = "ios"
      else
        device_token = @friend_request.recipient.android_device_token
        type = "android"
      end
      data = { notify_type: "send_friend_request", sender_user_id: sender_user_id, recipient_user_id: @friend_request.recipient.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message, trip_location_id: 0, trip_id: 0 }
      Notification.send_push_notification(data) if device_token.present?
    end

    respond_to do |format|
      format.js
      format.html { redirect_back fallback_location: root_path, notice: "Friend request was sent successfully" }
    end
  end

  def destroy
    @friend_request_id = params[:id]

    # Friend request does not exist when the recipient user has declined or accepted the invite,
    # and the sender has not reloaded the page.
    FriendRequest.find_by_id(@friend_request_id)&.destroy

    respond_to do |format|
      format.js
      format.html { redirect_back fallback_location: root_path, notice: "Friend request was declined successfully" }
    end
  end

  def accept
    @friend_request_id = params[:id]
    friend_request = FriendRequest.find_by_id(@friend_request_id)

    # Friend request does not exist when the sender user has canceled the invite,
    # and the recipient has not reloaded the page.
    if friend_request
      friend_request.accept
      message = "has accepted your Friend Request."
      heading = "<a href=#{user_path(friend_request.recipient)}>#{friend_request.recipient.name}</a> #{message}"
      mobile_url = friend_request.friend_request_custom_email_html(friend_request.recipient, message, "accept_friend_request")
      push_message = "#{friend_request.recipient.name} #{message}"
      Notification.create(heading: heading, recipient: friend_request.sender, sender: friend_request.recipient, notify_type: "accept_friend_request", user_setting_key: UserSetting::NOTIFICATION_EMAIL_FRIEND_REQUESTS, context: mobile_url)
      if friend_request.sender.ios_device_token.present?  
        device_token = friend_request.sender.ios_device_token
        type = "ios"
      else
        device_token = friend_request.sender.android_device_token
        type = "android"
      end
      data = { notify_type: "accept_friend_request", sender_user_id: friend_request.recipient.id, recipient_user_id: friend_request.sender.id, name: current_user.name, device_token: device_token, device_type: type, message: push_message }
      Notification.send_push_notification(data) if device_token.present?
    end
    respond_to do |format|
      format.js
      format.html { redirect_back fallback_location: root_path, notice: "Friend request was accepted successfully" }
    end
  end
end
