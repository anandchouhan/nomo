class RemovefieldFromTripParticipants < ActiveRecord::Migration[5.2]
  def change
    remove_column :trip_invitation_requests, :status
    change_column :trip_participants, :status, :integer, :default => 0, :null => false
  end
end
