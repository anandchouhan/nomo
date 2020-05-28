class AddTypeToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :type, :string
  end
end
