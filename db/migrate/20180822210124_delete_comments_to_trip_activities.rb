class DeleteCommentsToTripActivities < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DELETE FROM comments where id IN (
        SELECT comments.id
        FROM comments
        INNER JOIN activities ON activities.id = comments.commentable_id
        WHERE comments.commentable_type = 'Activity' AND activities.trackable_type = 'Trip'
      );
    SQL
  end
end
