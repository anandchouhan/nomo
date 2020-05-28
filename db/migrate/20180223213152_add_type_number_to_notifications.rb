class AddTypeNumberToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :type_number, :integer
  end
end
