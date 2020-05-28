class RemoveUnusedColumnsFromComments < ActiveRecord::Migration[5.2]
  def change
    remove_column :comments, :from_feed
  end
end
