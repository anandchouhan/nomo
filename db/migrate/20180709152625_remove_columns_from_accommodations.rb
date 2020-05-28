class RemoveColumnsFromAccommodations < ActiveRecord::Migration[5.2]
  def change
    remove_column :accommodations, :hotel_url
    remove_column :accommodations, :loyalty_account_number
  end
end
