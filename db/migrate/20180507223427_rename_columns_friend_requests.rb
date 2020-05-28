class RenameColumnsFriendRequests < ActiveRecord::Migration[5.1]
  def change
    rename_column :friend_requests, :origin_user_id, :sender_user_id
    rename_column :friend_requests, :destination_user_id, :recipient_user_id
  end
end
