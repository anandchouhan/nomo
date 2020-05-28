class DropInformationRelatedWithCircles < ActiveRecord::Migration[5.1]
  def change
    remove_column :polls, :circle_id
    remove_column :trips, :circle_id

    drop_table :circle_users
    drop_table :circles
  end
end
