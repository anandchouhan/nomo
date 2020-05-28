class AddRecipientTypeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :recipient_type, :string
  end
end
