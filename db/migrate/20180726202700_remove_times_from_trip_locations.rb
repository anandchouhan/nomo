class RemoveTimesFromTripLocations < ActiveRecord::Migration[5.2]
  def change
    change_column :trip_locations, :start_at, :date, null: false
    change_column :trip_locations, :end_at, :date, null: false
  end
end
