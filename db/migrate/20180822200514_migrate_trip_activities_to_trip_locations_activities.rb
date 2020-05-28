class MigrateTripActivitiesToTripLocationsActivities < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO activities (trackable_id, trackable_type, created_at, updated_at)
      SELECT trip_locations.id, 'TripLocation', trip_locations.created_at, trip_locations.updated_at
      FROM activities
      INNER JOIN trip_locations ON trip_locations.trip_id = activities.trackable_id
      WHERE activities.trackable_type = 'Trip';
    SQL
  end
end
