class RenameObjectTypeToObjectKlassInActivities < ActiveRecord::Migration
  def change
    rename_column :activities, :object_type, :object_klass
  end
end
