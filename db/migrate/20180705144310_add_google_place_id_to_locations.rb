class AddGooglePlaceIdToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :google_place_id, :string
    add_column :locations, :formatted_address, :string

    add_index :locations, :google_place_id, unique: true
  end
end
