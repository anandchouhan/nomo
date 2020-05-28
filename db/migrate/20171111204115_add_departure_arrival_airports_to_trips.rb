class AddDepartureArrivalAirportsToTrips < ActiveRecord::Migration
  def change
    remove_column :trips, :airport, :string
    remove_column :trips, :airport_code, :string
    add_column :trips, :departure_airport, :string
    add_column :trips, :arrival_airport, :string
    add_column :trips, :departure_airport_code, :string
    add_column :trips, :arrival_airport_code, :string
  end
end
