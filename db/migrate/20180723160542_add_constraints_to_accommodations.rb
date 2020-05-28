class AddConstraintsToAccommodations < ActiveRecord::Migration[5.2]
  def change
    change_column :accommodations, :trip_location_id, :bigint, null: false
    change_column :accommodations, :created_at, :datetime, null: false
    change_column :accommodations, :updated_at, :datetime, null: false
  end
end
