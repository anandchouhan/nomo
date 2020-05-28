class ChangeStartAndEndDateTypeInSearch < ActiveRecord::Migration
  def change
    remove_column :searches, :start_date, :string
    remove_column :searches, :end_date, :string
    add_column :searches, :start_date, :datetime
    add_column :searches, :end_date, :datetime
  end
end
