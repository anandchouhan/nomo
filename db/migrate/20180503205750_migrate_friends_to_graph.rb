class MigrateFriendsToGraph < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      INSERT INTO edges (origin_node_id, destination_node_id, context)
        SELECT DISTINCT
          origin.id AS origin_node_id, 
          destination.id AS destination_node_id,
          'friendship' AS context
        FROM circle_users
        INNER JOIN circles
          ON circles.id = circle_users.circle_id
        INNER JOIN nodes AS origin
          ON origin.nodeable_id = circles.owner_id
        INNER JOIN nodes AS destination
          ON destination.nodeable_id = circle_users.user_id
        WHERE circles.name = 'default'
          AND circle_users.user_id != circle_users.owner_id
          AND circle_users.is_approved = 't'
          AND circle_users.is_pending = 'f'
          AND origin.nodeable_type = 'User'
          AND destination.nodeable_type = 'User'
    SQL
  end
end
