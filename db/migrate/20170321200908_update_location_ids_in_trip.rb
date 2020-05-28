class UpdateLocationIdsInTrip < ActiveRecord::Migration
  def change
    rename_column :trips, :departing_from, :departing_from_id
    rename_column :trips, :destined_for, :destined_for_id
  end
end
