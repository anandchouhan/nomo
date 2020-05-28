class MigrateEvents < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO events (trip_location_id, name, start_at, end_at, description, location_id, created_at, updated_at)
      SELECT trip_locations.id, events.name, events.start_at, events.end_at, events.description, events.location_id, events.created_at, events.updated_at
      FROM trip_locations
      INNER JOIN events ON events.trip_id = trip_locations.trip_id;
    SQL
  end
end
