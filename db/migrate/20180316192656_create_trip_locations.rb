class CreateTripLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :trip_locations do |t|
      t.references :trip, index: true, null: false, foreign_key: true
      t.references :location, index: true, null: false, foreign_key: true
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false

      t.timestamps null: false
    end
  end
end
