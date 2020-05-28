class AddAirportToTrips < ActiveRecord::Migration
  def up
    add_column :trips, :airport, :string
    add_column :trips, :airport_code, :string
  end

  def down
    remove_column :trips, :airport, :string
    remove_column :trips, :airport_code, :string
  end
end
