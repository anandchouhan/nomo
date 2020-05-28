class AddObjectToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :objects, :text
  end
end
