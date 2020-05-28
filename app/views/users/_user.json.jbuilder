json.extract! user, :id, :username, :name, :email, :encrypted_password, :salt, :provider, :uid, :oauth_token, :oauth_expires_at, :created_at, :updated_at
json.url user_url(user, format: :json)
