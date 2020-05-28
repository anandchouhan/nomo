class AddAccountCreatedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_created, :boolean, default: false
  end
end
