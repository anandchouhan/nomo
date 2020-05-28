class AddCircleToPoll < ActiveRecord::Migration
  def change
    add_reference :polls, :circle
  end
end
