class ImproveNotifications < ActiveRecord::Migration[5.2]
  def change
    rename_column :notifications, :recipient_id, :recipient_user_id
    rename_column :notifications, :sender_id, :sender_user_id
    remove_column :notifications, :type_number
    add_column :notifications, :user_setting_key, :string
  end
end
