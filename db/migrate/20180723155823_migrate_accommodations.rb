class MigrateAccommodations < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO accommodations (trip_location_id, name, arriving_at, departing_at, reservation_number, hotel_address, description, created_at, updated_at)
      SELECT trip_locations.id, accommodations.name, accommodations.arriving_at, accommodations.departing_at, accommodations.reservation_number, accommodations.hotel_address, accommodations.description, trip_locations.created_at, trip_locations.updated_at
      FROM trip_locations
      INNER JOIN accommodations ON accommodations.trip_id = trip_locations.trip_id;
    SQL
  end
end
