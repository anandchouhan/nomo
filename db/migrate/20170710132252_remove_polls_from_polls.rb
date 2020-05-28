class RemovePollsFromPolls < ActiveRecord::Migration
  def change
    remove_reference :polls, :parent, foreign_key: true
  end
end
