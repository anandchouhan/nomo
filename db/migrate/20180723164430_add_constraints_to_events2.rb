class AddConstraintsToEvents2 < ActiveRecord::Migration[5.2]
  def change
    change_column :events, :trip_location_id, :bigint, null: false
  end
end
