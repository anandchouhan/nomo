class RemoveDefaultWaitlistPosition < ActiveRecord::Migration
  def change
    change_column_default(:waitlists, :position, nil)
  end
end
