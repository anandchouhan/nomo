class MigrateCommentsToTripLocationsActivities < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO comments (body, user_id, picture, commentable_id, commentable_type, created_at, updated_at)
      SELECT comments.body, comments.user_id, comments.picture, trip_location_activities.id, 'Activity', comments.created_at, comments.updated_at
      FROM comments
      INNER JOIN activities AS trip_activities ON trip_activities.id = comments.commentable_id
      INNER JOIN trips ON trips.id = trip_activities.trackable_id
      INNER JOIN trip_locations ON trip_locations.trip_id = trips.id
      INNER JOIN activities AS trip_location_activities ON trip_location_activities.trackable_id = trip_locations.id
      WHERE comments.commentable_type = 'Activity'
      AND trip_activities.trackable_type = 'Trip'
      AND trip_location_activities.trackable_type = 'TripLocation';
    SQL
  end
end
