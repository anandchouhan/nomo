class RemoveUnusedColumnsFromTravels < ActiveRecord::Migration[5.2]
  def change
    remove_column :travels, :loyalty_account_number
    remove_column :travels, :departure_airport_code
    remove_column :travels, :arrival_airport_code
  end
end
