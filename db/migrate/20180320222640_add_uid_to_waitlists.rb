class AddUidToWaitlists < ActiveRecord::Migration[4.2]
  def change
    add_column :waitlists, :uid, :string
  end
end
