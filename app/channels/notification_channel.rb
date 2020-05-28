class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_for "notifications"
  end
end