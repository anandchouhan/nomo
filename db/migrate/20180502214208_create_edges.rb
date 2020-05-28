class CreateEdges < ActiveRecord::Migration[5.1]
  def change
    create_table :edges do |t|
      t.references :origin_node, references: :nodes, null: false
      t.references :destination_node, references: :nodes, null: false
      t.string :context, null: false
      t.index [:origin_node_id, :destination_node_id, :context], unique: true, name: "uniqueness_edges"
    end
  end
end
