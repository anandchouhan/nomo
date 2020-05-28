class CreateUserSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :user_settings do |t|
      t.references :user, index: true, null: false, foreign_key: true
      t.string :key, null: false
      t.string :value, null: false

      t.timestamps
    end
  end
end
