class ChangeTimeDatatypeToAnalytics < ActiveRecord::Migration[5.2]
  def change
    change_column :analytics, :start_time, :bigint
    change_column :analytics, :end_time, :bigint
    change_column :analytics, :time_difference, :bigint
  end
end
