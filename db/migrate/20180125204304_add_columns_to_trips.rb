class AddColumnsToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :privacy_settings, :string, default: "FriendsOfFriends", null: false
  end
end
