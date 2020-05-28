class AddLocationPrivacyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :location_privacy, :integer, null: false, default: 3
  end
end
