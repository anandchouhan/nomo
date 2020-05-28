class AddNotNullConstraintsAccommodationsTravelsEvents < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      UPDATE accommodations SET arriving_at = current_timestamp WHERE arriving_at IS NULL;
      UPDATE accommodations SET departing_at = current_timestamp WHERE departing_at IS NULL;
      UPDATE travels SET departing_at = current_timestamp WHERE departing_at IS NULL;
      UPDATE travels SET arriving_at = current_timestamp WHERE arriving_at IS NULL;
      UPDATE events SET start_at = current_timestamp WHERE start_at IS NULL;
      UPDATE events SET end_at = current_timestamp WHERE end_at IS NULL;
    SQL

    change_column :accommodations, :arriving_at, :datetime, null: false
    change_column :accommodations, :departing_at, :datetime, null: false
    change_column :travels, :departing_at, :datetime, null: false
    change_column :travels, :arriving_at, :datetime, null: false
    change_column :events, :start_at, :datetime, null: false
    change_column :events, :end_at, :datetime, null: false
  end
end
