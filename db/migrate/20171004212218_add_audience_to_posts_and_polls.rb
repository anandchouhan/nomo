class AddAudienceToPostsAndPolls < ActiveRecord::Migration
  def change
    add_column :circles, :post_audience_id, :integer
    add_column :circles, :poll_audience_id, :integer
  end
end
