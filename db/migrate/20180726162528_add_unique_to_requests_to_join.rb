class AddUniqueToRequestsToJoin < ActiveRecord::Migration[5.2]
  def change
    add_index :requests_to_join, [:trip_location_id, :user_id], unique: true
  end
end
