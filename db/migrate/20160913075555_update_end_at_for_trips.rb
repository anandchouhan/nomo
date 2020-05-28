class UpdateEndAtForTrips < ActiveRecord::Migration
  def change
    remove_column :trips, :end_at, :time
    add_column :trips, :end_at, :date
  end
end
