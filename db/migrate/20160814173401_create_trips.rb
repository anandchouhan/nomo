class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.references :location, index: true, foreign_key: true
      t.date :start_at
      t.time :end_at
      t.string :type

      t.timestamps null: false
    end
  end
end
