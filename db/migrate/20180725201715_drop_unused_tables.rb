class DropUnusedTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :trip_participants
    drop_table :trip_invitation_requests
  end
end
