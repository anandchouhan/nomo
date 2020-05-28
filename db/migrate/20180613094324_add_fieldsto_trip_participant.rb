class AddFieldstoTripParticipant < ActiveRecord::Migration[5.2]
  def change
  	add_column :trip_participants, :from, :datetime
  	add_column :trip_participants, :to, :datetime
  	add_column :trip_participants, :interested, :boolean
  	add_column :trip_participants, :accepted, :boolean
  	add_column :trip_participants, :rejected, :boolean

  	add_column :trip_invitation_requests, :from, :datetime
  	add_column :trip_invitation_requests, :to, :datetime
  	add_column :trip_invitation_requests, :interested, :boolean
  	add_column :trip_invitation_requests, :accepted, :boolean
  	add_column :trip_invitation_requests, :rejected, :boolean
  end
end
