class AddRawDataColumn < ActiveRecord::Migration
  def change
    add_column :users, :raw_data, :text
  end
end
