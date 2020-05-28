class MigrateTripsAndUsersToGraph < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      INSERT INTO edges (origin_node_id, destination_node_id, context)
        SELECT DISTINCT
          origin.id AS origin_node_id, 
          destination.id AS destination_node_id,
          'joining' AS context
        FROM trips
        INNER JOIN circles
          ON circles.id = trips.circle_id
        INNER JOIN circle_users
          ON circle_users.circle_id = circles.id
        INNER JOIN nodes AS origin
          ON origin.nodeable_id = trips.id
        INNER JOIN nodes AS destination
          ON destination.nodeable_id = circle_users.user_id
        WHERE origin.nodeable_type = 'Trip' AND destination.nodeable_type = 'User';

      INSERT INTO edges (origin_node_id, destination_node_id, context)
        SELECT DISTINCT
          origin.id AS origin_node_id, 
          destination.id AS destination_node_id,
          'joining' AS context
        FROM trips
        INNER JOIN circles
          ON circles.id = trips.circle_id
        INNER JOIN circle_users
          ON circle_users.circle_id = circles.id
        INNER JOIN nodes AS origin
          ON origin.nodeable_id = circle_users.user_id
        INNER JOIN nodes AS destination
          ON destination.nodeable_id = trips.id
        WHERE origin.nodeable_type = 'User' AND destination.nodeable_type = 'Trip';

      INSERT INTO edges (origin_node_id, destination_node_id, context)
        SELECT DISTINCT
          origin.id AS origin_node_id,
          destination.id AS destination_node_id,
          'joining' AS context
        FROM trips
        INNER JOIN users
          ON users.id = trips.user_id
        INNER JOIN nodes AS origin
          ON origin.nodeable_id = trips.id
        INNER JOIN nodes AS destination
          ON destination.nodeable_id = users.id
        WHERE origin.nodeable_type = 'Trip' AND destination.nodeable_type = 'User'
      ON CONFLICT DO NOTHING;

      INSERT INTO edges (origin_node_id, destination_node_id, context)
        SELECT DISTINCT
          origin.id AS origin_node_id,
          destination.id AS destination_node_id,
          'joining' AS context
        FROM trips
        INNER JOIN users
          ON users.id = trips.user_id
        INNER JOIN nodes AS origin
          ON origin.nodeable_id = users.id
        INNER JOIN nodes AS destination
          ON destination.nodeable_id = trips.id
        WHERE origin.nodeable_type = 'User' AND destination.nodeable_type = 'Trip'
      ON CONFLICT DO NOTHING;
    SQL
  end
end
