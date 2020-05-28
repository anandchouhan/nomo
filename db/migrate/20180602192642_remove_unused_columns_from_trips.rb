class RemoveUnusedColumnsFromTrips < ActiveRecord::Migration[5.2]
  def change
    remove_column :trips, :comment, :string
    remove_column :trips, :type, :string
    remove_column :trips, :departing_from_id, :integer
    remove_column :trips, :destined_for_id, :integer
    remove_column :trips, :departing_at, :datetime
    remove_column :trips, :arriving_at, :datetime
    remove_column :trips, :parent_trip_id, :integer
    remove_column :trips, :reservation_number, :string
    remove_column :trips, :airline, :string
    remove_column :trips, :flight_number, :string
    remove_column :trips, :connection_time, :string
    remove_column :trips, :loyalty_account_number, :string
    remove_column :trips, :hotel, :string
    remove_column :trips, :hotel_address, :string
    remove_column :trips, :hotel_url, :string
    remove_column :trips, :check_in_time, :datetime
    remove_column :trips, :check_out_time, :datetime
    remove_column :trips, :departure_airport, :string
    remove_column :trips, :arrival_airport, :string
    remove_column :trips, :departure_airport_code, :string
    remove_column :trips, :arrival_airport_code, :string
  end
end