class AddUserToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :user_id, :integer
    add_column :events, :created_at, :datetime, null: false
    add_column :events, :updated_at, :datetime, null: false
    add_column :communities, :created_at, :datetime, null: false
    add_column :communities, :updated_at, :datetime, null: false
  end
end
