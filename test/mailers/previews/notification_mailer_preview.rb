# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  include Rails.application.routes.url_helpers

  def new_notification_preview
    NotificationMailer.new_notification_email(User.first, "<a href=#{profile_path(User.last)}>#{User.last.name}</a> has requested to join <a href=#{trip_path(Trip.first)}>#{Trip.first.name}</a>.", Time.now, User.last.profile_image)
  end
end
