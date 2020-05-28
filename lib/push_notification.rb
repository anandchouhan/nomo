require "houston"

class PushNotification
  
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
    notification.badge = 1
    notification.sound = "sosumi.aiff"
    notification.category = "INVITE_CATEGORY"
    notification.content_available = true
    notification.mutable_content = true
    notification.custom_data = @data

    # And... sent! That's all it takes.
    if @type == "ios"
      push_notification.push(notification)
    end
    
    # unless Rpush::Apns::App.first.present?
    #   app = Rpush::Apns::App.new
    #   app.name = "ios_app"
    #   cert_path = if Rails.env == "production"
    #                 File.expand_path("../config/push_notifications/ios/production/APNS-production.pem", _dir_)
    #               else
    #                 File.expand_path("../config/push_notifications/ios/development/APNS-Development.pem", _dir_)
    #               end
    #   app.certificate = File.read(cert_path)
    #   app.environment = Rails.env
    #   app.password = "server"
    #   app.connections = 1
    #   app.save! 
    # end

    # # unless Rpush::Pushy::App.first.present?
    # #   app = Rpush::Pushy::App.new
    # #   app.name = "android_app"
    # #   app.api_key = " "
    # #   app.connections = 1
    # #   app.save!
    # # end
    # if @type == "ios"
    #   ios_push_notification
    # elsif @type == "android"
    #   android_push_notification
    # end
  end

  # def ios_push_notification
  #   n = Rpush::Apns::Notification.new
  #   n.app = Rpush::Apns::App.find_by_name("ios_app")
  #   n.device_token = @device_token 
  #   @data = @data.reject! { |k| %i(device_type device_token message).include?(k) }
  #   n.alert = @message
  #   n.data = @data
  #   n.save!
  # end

  # def android_push_notification
  #   n = Rpush::Pushy::Notification.new
  #   n.app = Rpush::Pushy::App.find_by_name("android_app")
  #   n.registration_ids = [@device_token]
  #   @data = @data.reject! { |k| %i(device_type device_token message).include?(k) }
  #   n.data = @data
  #   n.time_to_live = 60 
  #   n.save!
  # end
end
