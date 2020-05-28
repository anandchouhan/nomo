class RemoveUnusedColumsFromComments < ActiveRecord::Migration[5.2]
  def change
    remove_column :comments, :public
    remove_column :comments, :trip_id
  end
end
