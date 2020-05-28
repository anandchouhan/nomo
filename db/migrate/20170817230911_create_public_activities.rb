# Migration responsible for creating a table with activities
class CreatePublicActivities < ActiveRecord::Migration
  # Create table
  def self.up
    create_table :public_activities do |t|
      t.belongs_to :trackable, polymorphic: true
      t.belongs_to :owner, polymorphic: true
      t.string  :key
      t.text    :parameters
      t.belongs_to :recipient, polymorphic: true

      t.timestamps
    end

    add_index :public_activities, %i[trackable_id trackable_type]
    add_index :public_activities, %i[owner_id owner_type]
    add_index :public_activities, %i[recipient_id recipient_type]
  end

  # Drop table
  def self.down
    drop_table :public_activities
  end
end
