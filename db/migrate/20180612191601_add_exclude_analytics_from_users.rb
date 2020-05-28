class AddExcludeAnalyticsFromUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :exclude_analytics, :boolean, default: false
  end
end
