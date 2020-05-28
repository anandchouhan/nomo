class AddColumnsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :twitter_id, :string
    add_column :profiles, :facebook_id, :string
    add_column :profiles, :instagram_id, :string
    add_column :profiles, :linked_in_id, :string
  end
end
