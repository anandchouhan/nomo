class AddcurrentStepToUser < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :current_step, :string
  end
end
