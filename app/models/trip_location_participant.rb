class TripLocationParticipant < ApplicationRecord
  belongs_to :trip_location, inverse_of: :trip_location_participants
  belongs_to :user

  after_create :delete_accept_request_notification
  after_destroy :delete_remove_request_notification

  def delete_accept_request_notification
    Notification.where("recipient_user_id = ? AND trip_location_id = ? AND sender_user_id = ? AND notify_type = ?", trip_location.trip.user, trip_location_id, user_id, "join_trip").destroy_all
  end

  def delete_remove_request_notification
    Notification.where("recipient_user_id = ? AND trip_location_id = ? AND notify_type = ?", user_id, trip_location_id, "accept_join_request").destroy_all
  end
end
