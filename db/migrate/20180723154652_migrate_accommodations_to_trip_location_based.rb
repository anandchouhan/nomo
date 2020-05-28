class MigrateAccommodationsToTripLocationBased < ActiveRecord::Migration[5.2]
  def change
    add_reference :accommodations, :trip_location, index: true
    add_foreign_key :accommodations, :trip_locations
    change_column :accommodations, :trip_id, :bigint, null: true
  end
end
