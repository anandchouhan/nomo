class AddDeviceTypeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :device_type, :string
    add_column :users, :vs, :float
  end
end
