class AddOwnerToCircle < ActiveRecord::Migration
  def change
    add_reference :circles, :owner
  end
end
