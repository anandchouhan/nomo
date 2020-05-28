class AddRefreshTokenAndContactsToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :refresh_token, :string
    add_column :identities, :contacts, :text, array: true, default: []
  end
end
