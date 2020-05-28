class AddPositionSequenceToWaitlist < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER SEQUENCE position_seq OWNED BY waitlists.position;
      ALTER TABLE waitlists ALTER COLUMN position SET DEFAULT nextval('position_seq');
    SQL
  end

  def down
    execute <<-SQL
      ALTER SEQUENCE position_seq OWNED BY NONE;
      ALTER TABLE waitlists ALTER COLUMN position SET NOT NULL;
    SQL
  end
end
