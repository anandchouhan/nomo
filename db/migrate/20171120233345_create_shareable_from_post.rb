class CreateShareableFromPost < ActiveRecord::Migration
  def change
    remove_foreign_key :posts, :parent
    remove_reference :posts, :parent, references: :posts, index: true
    remove_column :posts, :parent_type
    change_table :posts do |t|
      t.references :parent, polymorphic: true, index: true
    end
  end
end
