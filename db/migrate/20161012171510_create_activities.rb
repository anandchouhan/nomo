class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, index: true, foreign_key: true
      t.string :heading
      t.integer :object_id
      t.text :object_type

      t.timestamps null: false
    end
  end
end
