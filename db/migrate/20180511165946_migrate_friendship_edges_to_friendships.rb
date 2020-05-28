class MigrateFriendshipEdgesToFriendships < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      INSERT INTO friendships (origin_user_id, destination_user_id)
        SELECT origin_nodes.nodeable_id AS origin_user_id, destination_nodes.nodeable_id AS destination_user_id
        FROM nodes AS origin_nodes
        INNER JOIN edges ON edges.origin_node_id = origin_nodes.id
        INNER JOIN nodes AS destination_nodes ON edges.destination_node_id = destination_nodes.id
        WHERE edges.context = 'friendship';
    SQL
  end
end
