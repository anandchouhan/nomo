class AddConstraintsToTravels < ActiveRecord::Migration[5.2]
  def change
    change_column :travels, :trip_location_id, :bigint, null: false
    change_column :travels, :created_at, :datetime, null: false
    change_column :travels, :updated_at, :datetime, null: false
  end
end
