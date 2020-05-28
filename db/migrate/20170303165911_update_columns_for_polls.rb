class UpdateColumnsForPolls < ActiveRecord::Migration
  def change
    rename_column :polls, :poll_id, :parent_id
    rename_column :polls, :poll_type, :parent_type
  end
end
