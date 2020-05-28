class MigrateTripsToActivities < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DELETE FROM activities;

      INSERT INTO activities(trackable_id, trackable_type, created_at, updated_at)
      SELECT id, 'Trip', created_at, updated_at
      FROM trips;
    SQL
  end
end
