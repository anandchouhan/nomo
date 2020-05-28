class AddOwnerTypeAndOwnerIdToPost < ActiveRecord::Migration
  def change
    add_reference :posts, :parent, references: :posts, index: true
    add_foreign_key :posts, :posts, column: :parent_id
    add_column :posts, :ownership_type, :string
  end
end
