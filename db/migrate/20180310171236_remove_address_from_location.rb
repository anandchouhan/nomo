class RemoveAddressFromLocation < ActiveRecord::Migration
  def change
    remove_column :locations, :address
  end
end
