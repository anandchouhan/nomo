class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.datetime :start_at
      t.datetime :end_at
      t.string :privacy_settings, default: "FriendsOfFriends", null: false
      t.text :description
      t.boolean :can_invite_friends
    end
  end
end
