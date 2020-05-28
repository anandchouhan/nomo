class AddFlightFieldsToTrip < ActiveRecord::Migration
  def up
    add_column :trips, :reservation_number, :string
    add_column :trips, :airline, :string
    add_column :trips, :flight_number, :string
    add_column :trips, :connection_time, :string
    add_column :trips, :loyalty_account_number, :string
    add_column :trips, :hotel, :string
    add_column :trips, :hotel_address, :string
    add_column :trips, :hotel_url, :string
    add_column :trips, :check_in_time, :string
    add_column :trips, :check_out_time, :string
  end

  def down
    remove_column :trips, :reservation_number, :string
    remove_column :trips, :airline, :string
    remove_column :trips, :flight_number, :string
    remove_column :trips, :connection_time, :string
    remove_column :trips, :loyalty_account_number, :string
    remove_column :trips, :hotel, :string
    remove_column :trips, :hotel_address, :string
    remove_column :trips, :hotel_url, :string
    remove_column :trips, :check_in_time, :string
    remove_column :trips, :check_out_time, :string
  end
end
