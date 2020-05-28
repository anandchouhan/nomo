class NotificationsController < ApplicationController
  def index
    @notifications = next_notifications_batch(0)
    Notification.mark_as_read current_user
  end

  # Called when an Ajax request is made to retrieve the next batch of activities
  def scroll_refresh
    @notifications = next_notifications_batch(params[:offset])
  end

  private

  def next_notifications_batch(offset)
    sql = "SELECT notifications.* FROM notifications WHERE recipient_user_id = :user_id ORDER BY created_at DESC LIMIT 20 OFFSET :offset"
    Notification.find_by_sql [sql, { user_id: current_user.id, offset: offset }]
  end
end
