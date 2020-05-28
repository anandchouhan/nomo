class DeviceTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ios_device_token, :string
    add_column :users, :android_device_token, :string
  end
end
