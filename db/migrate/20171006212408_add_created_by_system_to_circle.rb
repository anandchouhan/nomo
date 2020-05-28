class AddCreatedBySystemToCircle < ActiveRecord::Migration
  def change
    add_column :circles, :created_by_system, :boolean
  end
end
