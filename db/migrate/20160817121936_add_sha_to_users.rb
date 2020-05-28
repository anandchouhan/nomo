class AddShaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :raw_data_sha, :string
  end
end
