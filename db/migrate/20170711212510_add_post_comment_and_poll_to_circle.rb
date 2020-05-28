class AddPostCommentAndPollToCircle < ActiveRecord::Migration
  def change
    add_reference :circles, :post, index: true, foreign_key: true
    add_reference :circles, :poll, index: true, foreign_key: true
    add_reference :circles, :comment, index: true, foreign_key: true
  end
end
