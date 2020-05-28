class RemoveUnusedDataFromEvents < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DELETE FROM events WHERE trip_id IS NOT NULL;
    SQL

    remove_column :events, :trip_id
  end
end
