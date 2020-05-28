class AddColumnsToLocationsForCountires < ActiveRecord::Migration
  def change
    add_column :locations, :alpha2, :string
    add_column :locations, :alpha3, :string
    add_column :locations, :country_code, :string
    add_column :locations, :iso3166_2, :string
    add_column :locations, :region, :string
    add_column :locations, :sub_region, :string
    add_column :locations, :region_code, :string
    add_column :locations, :sub_region_code, :string
  end
end
