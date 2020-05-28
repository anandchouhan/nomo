class AddTripIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :trip_id, :integer
  end
end
