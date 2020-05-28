class AddIsApprovedToCircleUsers < ActiveRecord::Migration
  def change
    add_column :circle_users, :owner_id, :integer
    add_column :circle_users, :is_approved, :boolean
    add_column :circle_users, :is_pending, :boolean, default: true

    add_index(:circles, %i[name owner_id])
  end
end
