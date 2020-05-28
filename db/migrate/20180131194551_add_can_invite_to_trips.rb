class AddCanInviteToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :can_invite, :string, default: "MyNetwork", null: false
  end
end
