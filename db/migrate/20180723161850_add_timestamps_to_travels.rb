class AddTimestampsToTravels < ActiveRecord::Migration[5.2]
  def change
    add_column :travels, :created_at, :datetime
    add_column :travels, :updated_at, :datetime
  end
end
