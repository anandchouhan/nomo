class AddColumnZoomLevelToCountries < ActiveRecord::Migration
  def change
    add_column :locations, :zoom_level, :integer, default: 4
  end
end
