class AddCreatedByToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :created_by, :integer
  end
end
