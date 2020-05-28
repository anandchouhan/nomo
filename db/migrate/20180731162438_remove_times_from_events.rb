class RemoveTimesFromEvents < ActiveRecord::Migration[5.2]
  def change
    change_column :events, :start_at, :date, null: false
    change_column :events, :end_at, :date, null: false
  end
end
