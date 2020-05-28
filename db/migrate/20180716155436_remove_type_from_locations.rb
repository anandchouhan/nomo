class RemoveTypeFromLocations < ActiveRecord::Migration[5.2]
  def change
    remove_column :locations, :type
  end
end
