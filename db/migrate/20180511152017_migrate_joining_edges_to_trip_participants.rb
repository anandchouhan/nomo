class MigrateJoiningEdgesToTripParticipants < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      INSERT INTO trip_participants (trip_id, user_id)
        SELECT trip_nodes.nodeable_id AS trip_id, user_nodes.nodeable_id AS user_id
        FROM nodes AS trip_nodes
        INNER JOIN edges ON edges.origin_node_id = trip_nodes.id
        INNER JOIN nodes AS user_nodes ON user_nodes.id = edges.destination_node_id
        WHERE trip_nodes.nodeable_type = 'Trip'
          AND user_nodes.nodeable_type = 'User'
          AND edges.context = 'joining';
    SQL
  end
end
