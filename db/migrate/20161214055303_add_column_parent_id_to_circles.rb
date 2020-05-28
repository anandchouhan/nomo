class AddColumnParentIdToCircles < ActiveRecord::Migration
  def change
    add_column :circles, :parent_id, :integer, index: true
  end
end
