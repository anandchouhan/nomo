class CreateRequestsToJoin < ActiveRecord::Migration[5.2]
  def change
    create_table :requests_to_join do |t|
      t.references :trip_location, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
