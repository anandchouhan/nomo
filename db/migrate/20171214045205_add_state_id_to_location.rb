class AddStateIdToLocation < ActiveRecord::Migration
  def up
    add_column :locations, :state_id, :integer
  end
  def down
    remove_column :locations, :state_id, :integer
  end
end
