class AddNameToWaitlist < ActiveRecord::Migration
  def up
    add_column :waitlists, :name, :string
  end

  def down
    remove_column :waitlists, :name, :string
  end
end
