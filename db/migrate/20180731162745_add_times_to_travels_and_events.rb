class AddTimesToTravelsAndEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :travels, :departing_at_time, :string
    add_column :travels, :arriving_at_time, :string
    add_column :events, :start_at_time, :string
    add_column :events, :end_at_time, :string
  end
end
