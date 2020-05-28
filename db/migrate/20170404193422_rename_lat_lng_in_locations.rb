class RenameLatLngInLocations < ActiveRecord::Migration
  def change
    rename_column :locations, :latitude, :lat
    rename_column :locations, :longitude, :lng
  end
end
