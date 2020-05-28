class AddForeignKeysToEdgesAndFriendRequests < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :edges, :nodes, column: :origin_node_id
    add_foreign_key :edges, :nodes, column: :destination_node_id
    add_foreign_key :friend_requests, :users, column: :origin_user_id
    add_foreign_key :friend_requests, :users, column: :destination_user_id
  end
end
