class ChangeTokenToDateTimeInUsers < ActiveRecord::Migration
  def change
    change_column :users, :oauth_expires_at, :datetime
  end
end
