class AddTripsToComments < ActiveRecord::Migration
  def change
    add_reference :comments, :trip, index: true, foreign_key: true
  end
end
