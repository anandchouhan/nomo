class MigrateUsersToGraph < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      INSERT INTO nodes (nodeable_type, nodeable_id)
        SELECT 'User', id FROM users
    SQL
  end
end
