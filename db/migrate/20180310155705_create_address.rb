class CreateAddress < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address
    end
  end
end
