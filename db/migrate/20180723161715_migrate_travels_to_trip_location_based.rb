class MigrateTravelsToTripLocationBased < ActiveRecord::Migration[5.2]
  def change
    add_reference :travels, :trip_location, index: true
    add_foreign_key :travels, :trip_locations
    change_column :travels, :trip_id, :bigint, null: true
  end
end
