class AddNotNullContraintsToActivities < ActiveRecord::Migration[5.2]
  def change
    change_column :activities, :trackable_id, :integer, null: false
    change_column :activities, :trackable_type, :string, null: false
  end
end
