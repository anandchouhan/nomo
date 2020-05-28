class AddParentToPolls < ActiveRecord::Migration
  def change
    add_reference :polls, :parent, references: :polls, index: true
    add_foreign_key :polls, :polls, column: :parent_id
  end
end
