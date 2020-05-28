class RemoveUnusedDataFromAccommodations < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DELETE FROM accommodations WHERE trip_id IS NOT NULL;
    SQL

    remove_column :accommodations, :trip_id
  end
end
