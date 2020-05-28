class Friendship < ApplicationRecord
  belongs_to :origin, class_name: :User, foreign_key: :origin_user_id
  belongs_to :destination, class_name: :User, foreign_key: :destination_user_id

  after_create :delete_sent_request_notification
  after_destroy :delete_accept_request_notification

  def delete_sent_request_notification
    Notification.where("(recipient_user_id = ? AND sender_user_id = ? AND notify_type = ?) OR (recipient_user_id = ? AND sender_user_id = ? AND notify_type = ?)", origin_user_id, destination_user_id, "send_friend_request", destination_user_id, origin_user_id, "send_friend_request").destroy_all
  end

  def delete_accept_request_notification
    Notification.where("(recipient_user_id = ? AND sender_user_id = ? AND notify_type = ?) OR (recipient_user_id = ? AND sender_user_id = ? AND notify_type = ?)", origin_user_id, destination_user_id, "accept_friend_request", destination_user_id, origin_user_id, "accept_friend_request").destroy_all
  end
end
