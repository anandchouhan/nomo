class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :salt
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.date :oauth_expires_at

      t.timestamps null: false
    end
  end
end
