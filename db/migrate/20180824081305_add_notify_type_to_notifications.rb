class AddNotifyTypeToNotifications < ActiveRecord::Migration[5.2]
  def change
    rename_column :notifications, :recipient_type, :notify_type
    add_reference :notifications, :trip_location
  end
end
