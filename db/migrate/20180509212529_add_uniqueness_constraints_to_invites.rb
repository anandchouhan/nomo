class AddUniquenessConstraintsToInvites < ActiveRecord::Migration[5.1]
  def change
    add_index :friend_requests, [:sender_user_id, :recipient_user_id], unique: true, name: "uniqueness_friend_requests"
    add_index :trip_invitation_requests, [:trip_id, :sender_user_id, :recipient_user_id], unique: true, name: "uniqueness_trip_invitation_requests"
  end
end
