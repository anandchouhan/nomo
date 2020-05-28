class AddCommentsToPoll < ActiveRecord::Migration
  def change
    add_reference :comments, :poll, index: true, foreign_key: true
  end
end
