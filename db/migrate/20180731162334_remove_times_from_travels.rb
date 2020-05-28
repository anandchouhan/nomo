class RemoveTimesFromTravels < ActiveRecord::Migration[5.2]
  def change
    change_column :travels, :departing_at, :date, null: false
    change_column :travels, :arriving_at, :date, null: false
  end
end
