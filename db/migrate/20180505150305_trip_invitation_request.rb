class TripInvitationRequest < ActiveRecord::Migration[5.1]
  def change
    create_table :trip_invitation_requests do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :sender_user, references: :users, null: false
      t.references :recipient_user, references: :users, null: false
    end

    add_foreign_key :trip_invitation_requests, :users, column: :sender_user_id
    add_foreign_key :trip_invitation_requests, :users, column: :recipient_user_id
  end
end
