class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :heading
      t.string :context
      t.datetime :completed_at
      t.references :recipient
      t.text :objects

      t.timestamps null: false
    end
  end
end
