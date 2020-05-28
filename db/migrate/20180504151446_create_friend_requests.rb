class CreateFriendRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :friend_requests do |t|
      t.references :origin_user, references: :users, null: false
      t.references :destination_user, references: :users, null: false
    end
  end
end
