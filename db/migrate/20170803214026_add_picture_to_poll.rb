class AddPictureToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :picture, :string
  end
end
