class UpdateStartValueForPositionSeq < ActiveRecord::Migration
  def change
    execute "ALTER SEQUENCE position_seq RESTART WITH 230"
  end
end
