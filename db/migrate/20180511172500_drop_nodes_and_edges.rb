class DropNodesAndEdges < ActiveRecord::Migration[5.1]
  def change
    drop_table :edges
    drop_table :nodes
  end
end
