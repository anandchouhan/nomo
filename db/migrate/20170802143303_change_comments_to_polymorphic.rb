class ChangeCommentsToPolymorphic < ActiveRecord::Migration
  def change
    remove_reference :comments, :trip, index: true, foreign_key: true
    remove_reference :comments, :profile, index: true, foreign_key: true
    remove_reference :comments, :poll, index: true, foreign_key: true
    remove_reference :comments, :post, index: true, foreign_key: true
    add_reference    :comments, :commentable, polymorphic: true, index: true
  end
end
