class CreateWaitlists < ActiveRecord::Migration
  def change
    create_table :waitlists do |t|
      t.string :email
      t.string :referred_by
      t.string :referral_link
      t.integer :position
    end
    # ALTER SEQUENCE waitlists_position_seq RESTART WITH 300
    execute 'CREATE SEQUENCE position_seq START 300;'
  end
end
