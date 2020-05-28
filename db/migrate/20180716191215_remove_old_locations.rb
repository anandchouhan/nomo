class RemoveOldLocations < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DELETE FROM locations WHERE google_place_id IS NULL;
    SQL
  end
end
