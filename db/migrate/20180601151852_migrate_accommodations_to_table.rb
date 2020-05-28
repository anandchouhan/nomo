class MigrateAccommodationsToTable < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO accommodations (trip_id, name, arriving_at, departing_at, reservation_number, hotel_address, hotel_url, loyalty_account_number, description)
        SELECT trips.id,
          accommodations.name,
          accommodations.arriving_at,
          accommodations.departing_at,
          accommodations.reservation_number,
          accommodations.hotel_address,
          accommodations.hotel_url,
          accommodations.loyalty_account_number,
          accommodations.description
        FROM trips AS accommodations
        INNER JOIN trips ON trips.id = accommodations.parent_trip_id
        WHERE accommodations.type = 'Accomodation'
    SQL
  end
end
