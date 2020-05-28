class ChangeAssociationsWithEvents < ActiveRecord::Migration
  def change
    remove_column :events, :privacy_settings
    add_column :events, :location_id, :integer
    add_column :events, :community_id, :integer
  end
end
