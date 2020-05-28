class AddGoogleIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :google_id, :string
  end
end
