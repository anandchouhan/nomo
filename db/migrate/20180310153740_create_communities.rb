class CreateCommunities < ActiveRecord::Migration
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.text :description
      t.string :privacy_settings, default: "FriendsOfFriends", null: false
    end
  end
end
