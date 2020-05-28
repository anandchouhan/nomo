class AddAdminRoleToCircleUsers < ActiveRecord::Migration
  def change
    add_column :circle_users, :role, :string
  end
end
