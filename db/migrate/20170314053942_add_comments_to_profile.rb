class AddCommentsToProfile < ActiveRecord::Migration
  def change
    add_reference :comments, :profile, index: true, foreign_key: true
  end
end
