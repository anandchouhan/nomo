class AddSignupSourceAndAppVersionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :signup_source, :string
    add_column :users, :app_version, :float
  end
end
