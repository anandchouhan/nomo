class AddIsRequestedToCircleUsers < ActiveRecord::Migration
  def change
    add_column :circle_users, :is_requested, :boolean
  end
end
