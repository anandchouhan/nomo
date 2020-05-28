class FriendRequest < ApplicationRecord
  belongs_to :sender, class_name: :User, foreign_key: :sender_user_id
  belongs_to :recipient, class_name: :User, foreign_key: :recipient_user_id
  after_destroy :delete_sent_request_notification

  def accept
    ActiveRecord::Base.transaction do
      destroy
      Friendship.create(origin: sender, destination: recipient)
      Friendship.create(origin: recipient, destination: sender)
    end
  end

  def delete_sent_request_notification
    Notification.where("(recipient_user_id = ? AND sender_user_id = ? AND notify_type = ?) OR (recipient_user_id = ? AND sender_user_id = ? AND notify_type = ?)", recipient_user_id, sender_user_id, "send_friend_request", sender_user_id, recipient_user_id, "send_friend_request").destroy_all
  end

  def friend_request_custom_email_html(sender_user, message, type)
    web_url_user = "users/#{sender_user.id}"
    m_url_user = "nomo-fomo:/#{web_url_user}&notify_type=user_detail&notify_type=#{type}"
    mobile_url = "<a href=/mobile_notification?user_id=#{sender_user.id}&web_url=#{web_url_user}&mobile_url=#{m_url_user}>#{sender_user.name}</a>"
    mobile_url = type.include?("send") ? "#{message} #{mobile_url}" : "#{mobile_url} #{message}"
    mobile_url
  end
end
