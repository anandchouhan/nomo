class RemoveUnusedColumnsFromEvents < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :circle_id
    remove_column :events, :community_id
    remove_column :events, :can_invite_friends
  end
end
