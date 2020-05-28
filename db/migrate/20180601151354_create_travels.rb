class CreateTravels < ActiveRecord::Migration[5.2]
  def change
    create_table :travels do |t|
      t.references :trip, null: false, foreign_key: true
      t.string :name, null: false
      t.string :reservation_number
      t.string :airline
      t.string :flight_number
      t.string :loyalty_account_number
      t.string :description

      t.references :departure_location, references: :locations
      t.string :departure_airport
      t.string :departure_airport_code
      t.datetime :departing_at

      t.references :arrival_location, references: :locations
      t.string :arrival_airport
      t.string :arrival_airport_code
      t.datetime :arriving_at      
    end

    add_foreign_key :travels, :locations, column: :departure_location_id
    add_foreign_key :travels, :locations, column: :arrival_location_id
  end
end