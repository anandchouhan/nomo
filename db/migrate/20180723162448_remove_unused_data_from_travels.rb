class RemoveUnusedDataFromTravels < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DELETE FROM travels WHERE trip_id IS NOT NULL;
    SQL

    remove_column :travels, :trip_id
  end
end
