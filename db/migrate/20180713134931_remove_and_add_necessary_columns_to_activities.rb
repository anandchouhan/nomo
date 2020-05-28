class RemoveAndAddNecessaryColumnsToActivities < ActiveRecord::Migration[5.2]
  def change
    remove_column :activities, :user_id
    remove_column :activities, :heading
    remove_column :activities, :object_id
    remove_column :activities, :object_klass
    remove_column :activities, :objects

    add_column :activities, :trackable_id, :integer
    add_column :activities, :trackable_type, :string

    add_index :activities, [:trackable_id, :trackable_type]
  end
end
