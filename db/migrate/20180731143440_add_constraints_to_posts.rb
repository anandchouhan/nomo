class AddConstraintsToPosts < ActiveRecord::Migration[5.2]
  def change
    change_column :posts, :privacy, :integer, null: false
  end
end
