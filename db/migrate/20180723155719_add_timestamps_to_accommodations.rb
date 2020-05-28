class AddTimestampsToAccommodations < ActiveRecord::Migration[5.2]
  def change
    add_column :accommodations, :created_at, :datetime
    add_column :accommodations, :updated_at, :datetime
  end
end
