class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, :integer
    add_column :users, :website, :string
  end
end
