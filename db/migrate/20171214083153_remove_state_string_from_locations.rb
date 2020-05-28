class RemoveStateStringFromLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :state, :string
  end

  def down
    add_column :locations, :state, :string
  end
end
