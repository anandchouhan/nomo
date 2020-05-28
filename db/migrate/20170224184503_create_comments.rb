class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.boolean :public
      t.references :user, index: true, foreign_key: true, as: :author

      t.timestamps null: false
    end
  end
end
