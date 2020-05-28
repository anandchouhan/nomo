class AddConstraintsToEvents < ActiveRecord::Migration[5.2]
  def change
    change_column :travels, :trip_location_id, :bigint, null: false
  end
end
