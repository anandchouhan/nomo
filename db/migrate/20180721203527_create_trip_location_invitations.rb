class CreateTripLocationInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_location_invitations do |t|
      t.references :trip_location, null: false, foreign_key: true
      t.references :sender_user, references: :users, null: false
      t.references :recipient_user, references: :users, null: false

      t.timestamps
    end

    add_foreign_key :trip_location_invitations, :users, column: :sender_user_id
    add_foreign_key :trip_location_invitations, :users, column: :recipient_user_id
  end
end
