class AddstatusToTripPraticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :trip_participants, :status, :integer, null: false, default: 1
    remove_column :trip_participants, :interested, :boolean
    remove_column :trip_participants, :accepted, :boolean
    remove_column :trip_participants, :rejected, :boolean

    add_column :trip_invitation_requests, :status, :integer, null: false, default: 1
    remove_column :trip_invitation_requests, :interested, :boolean
    remove_column :trip_invitation_requests, :accepted, :boolean
    remove_column :trip_invitation_requests, :rejected, :boolean

    load Rails.root.join('db','seeds','trip_participants.rb').to_s
  end
end
