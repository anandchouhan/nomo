class AddUserIdToTrips < ActiveRecord::Migration
  def change
    add_reference :trips, :user
  end
end
