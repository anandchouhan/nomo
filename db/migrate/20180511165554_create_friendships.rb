class CreateFriendships < ActiveRecord::Migration[5.1]
  def change
    create_table :friendships do |t|
      t.references :origin_user, references: :users, null: false
      t.references :destination_user, references: :users, null: false
      t.index [:origin_user_id, :destination_user_id], unique: true, name: "uniqueness_friendships"
    end

    add_foreign_key :friendships, :users, column: :origin_user_id
    add_foreign_key :friendships, :users, column: :destination_user_id
  end
end
