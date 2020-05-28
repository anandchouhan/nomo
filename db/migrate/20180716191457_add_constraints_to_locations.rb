class AddConstraintsToLocations < ActiveRecord::Migration[5.2]
  def change
    remove_index :locations, name: :index_locations_on_city_id
    remove_index :locations, name: :index_locations_on_continent_id
    remove_index :locations, name: :index_locations_on_country_id

    change_column :locations, :google_place_id, :string, null: false
    change_column :locations, :formatted_address, :string, null: false
  end
end
