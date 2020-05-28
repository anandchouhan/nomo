class CreateAccommodations < ActiveRecord::Migration[5.2]
  def change
    create_table :accommodations do |t|
      t.references :trip, null: false, foreign_key: true
      t.string :name, null: false
      t.datetime :arriving_at
      t.datetime :departing_at
      t.string :reservation_number
      t.string :hotel_address
      t.string :hotel_url
      t.string :loyalty_account_number
      t.string :description
    end
  end
end