class CreateTripLocationParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_location_participants do |t|
      t.references :trip_location, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
