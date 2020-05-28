class RemoveAccommodationsAndTravelsFromTrips < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL

      DELETE
      FROM trip_participants
      WHERE trip_participants.trip_id IN (
        SELECT id
        FROM trips
        WHERE type = 'Accomodation' OR
              type = 'Travel' OR
              type = 'Nomad' OR
              type = 'Wishlist'
      );

      DELETE FROM trips
        WHERE trips.type = 'Accomodation' OR
        trips.type = 'Travel' OR
        trips.type = 'Nomad' OR
        trips.type = 'Wishlist';
    SQL
  end
end
