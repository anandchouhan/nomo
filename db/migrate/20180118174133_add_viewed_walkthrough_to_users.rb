class AddViewedWalkthroughToUsers < ActiveRecord::Migration
  def change
    add_column :users, :viewed_walkthrough, :integer
  end
end
