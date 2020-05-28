class AddLocationToSearch < ActiveRecord::Migration
  def change
    remove_reference :searches, :location
    add_reference :searches, :location, index: true, foreign_key: true
  end
end
