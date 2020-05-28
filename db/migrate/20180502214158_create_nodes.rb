class CreateNodes < ActiveRecord::Migration[5.1]
  def change
    create_table :nodes do |t|
      t.references :nodeable, polymorphic: true, index: true, null: false
      t.index [:nodeable_type, :nodeable_id], unique: true, name: "uniqueness_nodes"
    end
  end
end
