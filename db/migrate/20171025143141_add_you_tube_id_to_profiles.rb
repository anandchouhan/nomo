class AddYouTubeIdToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :youtube_id, :string
    add_column :profiles, :blog_id, :string
  end
end
