class MigrateTripsToGraph < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      INSERT INTO nodes (nodeable_type, nodeable_id)
        SELECT 'Trip', id FROM trips
    SQL
  end
end
