class CreateCommunityPrivacySettings < ActiveRecord::Migration
  def change
    create_table :community_privacy_settings do |t|
      t.references :community, foreign_key: true

      t.string :see_community_and_request_to_join, null: false, default: "public"
      t.string :be_added_or_invited_by_a_member, null: false, default: "public"
      t.string :see_community_name, null: false, default: "public"
      t.string :see_who_is_in_community, null: false, default: "public"
      t.string :see_community_description, null: false, default: "public"
      t.string :see_community_location, null: false, default: "public"
      t.string :see_what_members_post, null: false, default: "public"
      t.string :find_community_in_search, null: false, default: "public"
      t.string :see_stories_about_community_on_facebook, null: false, default: "public"

      t.timestamps null: false
    end
  end
end
