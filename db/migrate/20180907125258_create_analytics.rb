class CreateAnalytics < ActiveRecord::Migration[5.2]
  def change
    create_table :analytics do |t|
      t.string :device_type
      t.string :device_token
      t.integer :user_id   
      t.string :analytic_type   
      t.integer :start_time  
      t.integer :end_time  
      t.boolean :is_active, default: false
      t.integer :time_difference 
      t.float :version
      t.timestamps
    end
  end
end
