class AddCircleToTrips < ActiveRecord::Migration
  def change
    add_reference :trips, :circle
  end
end
