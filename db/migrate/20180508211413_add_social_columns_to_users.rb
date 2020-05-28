class AddSocialColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :twitter_id, :string
    add_column :users, :facebook_id, :string
    add_column :users, :instagram_id, :string
    add_column :users, :linked_in_id, :string
    add_column :users, :youtube_id, :string
    add_column :users, :blog_id, :string
  end
end
