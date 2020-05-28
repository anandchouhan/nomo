class AddConstraintsToParticipantsAndInvitations < ActiveRecord::Migration[5.2]
  def change
    add_index :trip_location_participants, [:trip_location_id, :user_id], unique: true, name: "unique_participants"
    add_index :trip_location_invitations, [:trip_location_id, :sender_user_id, :recipient_user_id], unique: true, name: "unique_invitations"
  end
end
