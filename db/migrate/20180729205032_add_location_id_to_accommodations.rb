class AddLocationIdToAccommodations < ActiveRecord::Migration[5.2]
  def change
    add_reference :accommodations, :location, index: true
    add_foreign_key :accommodations, :locations
  end
end
