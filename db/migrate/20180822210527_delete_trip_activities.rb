class DeleteTripActivities < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DELETE FROM activities WHERE activities.trackable_type = 'Trip';
    SQL
  end
end
