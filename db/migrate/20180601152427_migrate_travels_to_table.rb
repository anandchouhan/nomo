class MigrateTravelsToTable < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO travels (trip_id, name, reservation_number, airline, flight_number, loyalty_account_number, description, departure_location_id, departure_airport, departure_airport_code, departing_at, arrival_location_id, arrival_airport, arrival_airport_code, arriving_at)
        SELECT trips.id,
          travels.name,
          travels.reservation_number,
          travels.airline,
          travels.flight_number,
          travels.loyalty_account_number,
          travels.description,
          travels.departing_from_id,
          travels.departure_airport,
          travels.departure_airport_code,
          travels.departing_at,
          travels.destined_for_id,
          travels.arrival_airport,
          travels.arrival_airport_code,
          travels.arriving_at
        FROM trips AS travels
        INNER JOIN trips ON trips.id = travels.parent_trip_id
        WHERE travels.type = 'Travel'
    SQL
  end
end
