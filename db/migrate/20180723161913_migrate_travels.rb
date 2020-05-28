class MigrateTravels < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO travels (trip_location_id, name, reservation_number, airline, flight_number, description, departure_location_id, departure_airport, departing_at, arrival_location_id, arrival_airport, arriving_at, created_at, updated_at)
      SELECT trip_locations.id, travels.name, travels.reservation_number, travels.airline, travels.flight_number, travels.description, travels.departure_location_id, travels.departure_airport, travels.departing_at, travels.arrival_location_id, travels.arrival_airport, travels.arriving_at, trip_locations.created_at, trip_locations.updated_at
      FROM trip_locations
      INNER JOIN travels ON travels.trip_id = trip_locations.trip_id;
    SQL
  end
end
