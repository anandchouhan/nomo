class AddCircleIdToCommunitiesAndEvents < ActiveRecord::Migration
  def change
    add_column :communities, :circle_id, :integer
    add_column :events, :circle_id, :integer
    add_column :locations, :address, :string
  end
end
