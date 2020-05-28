class AddStatusToCircleUsers < ActiveRecord::Migration
  def change
    add_column :circle_users, :status, :string, default: ""
  end
end
