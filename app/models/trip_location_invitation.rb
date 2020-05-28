class TripLocationInvitation < ApplicationRecord
  belongs_to :trip_location, inverse_of: :trip_location_invitations
  belongs_to :sender, class_name: :User, foreign_key: :sender_user_id
  belongs_to :recipient, class_name: :User, foreign_key: :recipient_user_id

  after_destroy :delete_join_trip_notification

  def delete_join_trip_notification
    Notification.where("sender_user_id = ? AND trip_location_id = ? AND notify_type = ? AND recipient_user_id = ? ", sender_user_id, trip_location_id, "invite_trip", recipient_user_id).destroy_all
  end
end
