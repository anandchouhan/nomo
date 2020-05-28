class AddUserIdToAccommodationsEventsAndTravels < ActiveRecord::Migration[5.2]
  def change
  	add_column :accommodations, :user_id, :integer
    add_column :events, :user_id, :integer
    add_column :travels, :user_id, :integer
  end
end
