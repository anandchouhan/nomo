class RemovePrivacySettingsFromCommunities < ActiveRecord::Migration
  def change
    remove_column :communities, :privacy_settings
  end
end
