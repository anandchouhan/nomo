class AddParentTypeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :parent_type, :string
  end
end
