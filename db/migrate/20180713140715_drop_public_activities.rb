class DropPublicActivities < ActiveRecord::Migration[5.2]
  def change
    drop_table :public_activities
  end
end
