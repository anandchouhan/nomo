class AddfromFeedToComment < ActiveRecord::Migration[5.2]
  def change
  	add_column :comments, :from_feed, :boolean, default: false
  end
end
