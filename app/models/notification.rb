class Notification < ApplicationRecord
  belongs_to :sender, class_name: :User, foreign_key: :sender_user_id
  belongs_to :recipient, class_name: :User, foreign_key: :recipient_user_id
  belongs_to :trip_location, optional: true

  scope :unread, -> { where(is_read: false) }

  after_create_commit :send_email

  def mark_as_read
    update(is_read: true)
  end

  def self.mark_as_read(user)
    user.notifications.each(&:mark_as_read)
  end

  def self.send_push_notification(data)
    @data = data
    @device_token = data[:device_token]
    @type = data[:device_type]
    @message = data[:message]
    # Environment variables are automatically read, or can be overridden by any specified options. You can also
    # conveniently use `Houston::Client.development` or `Houston::Client.production`.
    push_notification = Houston::Client.production
    cert_path = "config/push_notifications/ios/production/apns-pro-nomo.pem"

    push_notification.certificate = File.read(cert_path)

    # An example of the token sent back when a device registers for notifications
    token = @device_token
    @data = @data.reject! { |k| %i(device_type device_token message).include?(k) }

    # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    notification = Houston::Notification.new(device: token)
    notification.alert = @message

    # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    not_read_count = Notification.where(recipient_user_id: @data[:recipient_user_id], is_read: false).count
    notification.badge = not_read_count
    notification.sound = "sosumi.aiff"
    notification.category = "INVITE_CATEGORY"
    notification.content_available = true
    notification.mutable_content = true
    notification.custom_data = @data

    # And... sent! That's all it takes.
    if @type == "ios"
      NotificationChannel.broadcast_to("notifications", data: @data)
      push_notification.push(notification)
    end
  end
  
  private

  def send_email
    profile_image = sender.present? ? sender.profile_image : "https://s3.us-east-2.amazonaws.com/nomofomo-assets/static/images/user.png"

    user_setting = recipient.user_settings.where(key: user_setting_key).take

    # NOTIFICATION_EMAIL_LIKES_IN_MY_ACTIVITY default value is off    
    if (user_setting.nil? && user_setting_key != UserSetting::NOTIFICATION_EMAIL_LIKES_IN_MY_ACTIVITY) || (!user_setting.nil? && user_setting.value == "on")
      NotificationMailer.new_notification_email(recipient, context, profile_image).deliver_later
    end
  end
end
