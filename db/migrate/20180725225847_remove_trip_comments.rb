class RemoveTripComments < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      DELETE FROM comments WHERE commentable_type = 'Trip';
    SQL
  end
end
