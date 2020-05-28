class MigrateTripParticipantsToTripLocationParticipants < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO trip_location_participants (trip_location_id, user_id, created_at, updated_at)
      SELECT trip_locations.id, trip_participants.user_id, trip_locations.created_at, trip_locations.updated_at
      FROM trip_locations
      INNER JOIN trip_participants ON trip_locations.trip_id = trip_participants.trip_id;
    SQL
  end
end
