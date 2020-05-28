class AddTimesToAccommodations < ActiveRecord::Migration[5.2]
  def change
    add_column :accommodations, :arriving_at_time, :string
    add_column :accommodations, :departing_at_time, :string
  end
end
