class MigrateTripsToMultipleLocations < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      INSERT INTO trip_locations (trip_id, location_id, start_at, end_at, created_at, updated_at)
        SELECT id, location_id, start_at, end_at, created_at, updated_at
        FROM trips
        WHERE location_id IS NOT NULL
          AND start_at IS NOT NULL
          AND end_at IS NOT NULL
          AND (type IS NULL OR type = '')
    SQL

    remove_column :trips, :location_id
    remove_column :trips, :start_at
    remove_column :trips, :end_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
