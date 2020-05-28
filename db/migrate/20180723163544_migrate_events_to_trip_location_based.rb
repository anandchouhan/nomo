class MigrateEventsToTripLocationBased < ActiveRecord::Migration[5.2]
  def change
    add_reference :events, :trip_location, index: true
    add_foreign_key :events, :trip_locations
  end
end
