class RequestToJoin < ApplicationRecord
  belongs_to :trip_location
  belongs_to :user

  after_destroy :delete_join_trip_notification

  def delete_join_trip_notification
    Notification.where("sender_user_id = ? AND trip_location_id = ? AND notify_type = ?", user_id, trip_location_id, "join_trip").destroy_all
  end
end
