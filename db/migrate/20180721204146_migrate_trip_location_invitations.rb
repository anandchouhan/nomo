class MigrateTripLocationInvitations < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      INSERT INTO trip_location_invitations (trip_location_id, sender_user_id, recipient_user_id, created_at, updated_at)
      SELECT trip_locations.id, trip_invitation_requests.sender_user_id, trip_invitation_requests.recipient_user_id, trip_locations.created_at, trip_locations.updated_at
      FROM trip_locations
      INNER JOIN trip_invitation_requests ON trip_invitation_requests.trip_id = trip_locations.trip_id;
    SQL
  end
end
