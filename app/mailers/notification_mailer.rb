class NotificationMailer < ApplicationMailer
  default from: "Nomo FOMO Team <contact@nomo-fomo.com>"

  add_template_helper ApplicationHelper

  def new_notification_email(user, context, image = "https://s3.us-east-2.amazonaws.com/nomofomo-assets/static/images/user.png")
    # headers["X-MJ-CustomID"] = "custom value"
    # headers["X-MJ-EventPayload"] = "custom payload"
    @user = user
    @content = context.gsub("href=", Rails.env == "development" ? "href=http://localhost:3000" : "href=https://nomo-fomo.com").html_safe
    @image = image
    mail(
      to: @user.email,
      subject: "You Have a New Notification"
    )
  end
end
