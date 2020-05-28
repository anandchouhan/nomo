class AddHometownAndLocationToUser < ActiveRecord::Migration
  def change
    add_reference :users, :hometown
    add_reference :users, :location
  end
end
