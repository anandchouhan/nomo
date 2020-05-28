class RemoveTimesFromAccommodations < ActiveRecord::Migration[5.2]
  def change
    change_column :accommodations, :arriving_at, :date, null: false
    change_column :accommodations, :departing_at, :date, null: false
  end
end
