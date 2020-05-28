class RemoveUnusedTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :facts
    drop_table :identities
    drop_table :landings
    drop_table :polls
    drop_table :posts
    drop_table :searches
    drop_table :user_locations
  end
end
