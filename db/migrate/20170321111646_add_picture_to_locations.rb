class AddPictureToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :picture, :string
  end
end
