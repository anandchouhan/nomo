class AddImageUrlToLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :locations, :image_url, :string
  end
end
