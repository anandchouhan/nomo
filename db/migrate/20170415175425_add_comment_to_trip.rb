class AddCommentToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :comment, :string
  end
end
