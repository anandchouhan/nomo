# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_12_112424) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "accommodations", force: :cascade do |t|
    t.string "name", null: false
    t.date "arriving_at", null: false
    t.date "departing_at", null: false
    t.string "reservation_number"
    t.string "hotel_address"
    t.string "description"
    t.bigint "trip_location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id"
    t.string "arriving_at_time"
    t.string "departing_at_time"
    t.integer "user_id"
    t.index ["location_id"], name: "index_accommodations_on_location_id"
    t.index ["trip_location_id"], name: "index_accommodations_on_trip_location_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trackable_id", null: false
    t.string "trackable_type", null: false
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "analytics", force: :cascade do |t|
    t.string "device_type"
    t.string "device_token"
    t.integer "user_id"
    t.string "analytic_type"
    t.bigint "start_time"
    t.bigint "end_time"
    t.boolean "is_active", default: false
    t.bigint "time_difference"
    t.float "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "app_version"
    t.string "email"
    t.string "metric_classification"
    t.string "metric_identifier"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "body"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "picture"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "communities", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "circle_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "community_privacy_settings", id: :serial, force: :cascade do |t|
    t.integer "community_id"
    t.string "see_community_and_request_to_join", default: "public", null: false
    t.string "be_added_or_invited_by_a_member", default: "public", null: false
    t.string "see_community_name", default: "public", null: false
    t.string "see_who_is_in_community", default: "public", null: false
    t.string "see_community_description", default: "public", null: false
    t.string "see_community_location", default: "public", null: false
    t.string "see_what_members_post", default: "public", null: false
    t.string "find_community_in_search", default: "public", null: false
    t.string "see_stories_about_community_on_facebook", default: "public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "default_settings", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.date "start_at", null: false
    t.date "end_at", null: false
    t.text "description"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "trip_location_id", null: false
    t.string "start_at_time"
    t.string "end_at_time"
    t.integer "user_id"
    t.index ["trip_location_id"], name: "index_events_on_trip_location_id"
  end

  create_table "friend_requests", force: :cascade do |t|
    t.bigint "sender_user_id", null: false
    t.bigint "recipient_user_id", null: false
    t.index ["recipient_user_id"], name: "index_friend_requests_on_recipient_user_id"
    t.index ["sender_user_id", "recipient_user_id"], name: "uniqueness_friend_requests", unique: true
    t.index ["sender_user_id"], name: "index_friend_requests_on_sender_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.bigint "origin_user_id", null: false
    t.bigint "destination_user_id", null: false
    t.index ["destination_user_id"], name: "index_friendships_on_destination_user_id"
    t.index ["origin_user_id", "destination_user_id"], name: "uniqueness_friendships", unique: true
    t.index ["origin_user_id"], name: "index_friendships_on_origin_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "image_path"
    t.integer "trip_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.string "likeable_type"
    t.bigint "likeable_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "lat"
    t.string "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "facebook_oid"
    t.string "name"
    t.integer "city_id"
    t.integer "country_id"
    t.integer "continent_id"
    t.string "street"
    t.string "zip"
    t.integer "created_by"
    t.string "iata"
    t.string "icao"
    t.float "altitude"
    t.string "timezone"
    t.string "dst"
    t.integer "zoom_level", default: 4
    t.string "alpha2"
    t.string "alpha3"
    t.string "country_code"
    t.string "iso3166_2"
    t.string "region"
    t.string "sub_region"
    t.string "region_code"
    t.string "sub_region_code"
    t.string "picture"
    t.string "google_id"
    t.integer "state_id"
    t.string "city_signature"
    t.string "image_url"
    t.string "google_place_id", null: false
    t.string "formatted_address", null: false
    t.index ["google_place_id"], name: "index_locations_on_google_place_id", unique: true
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "heading"
    t.string "context"
    t.datetime "completed_at"
    t.integer "recipient_user_id"
    t.text "objects"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notify_type"
    t.boolean "is_read", default: false
    t.integer "sender_user_id"
    t.string "user_setting_key"
    t.bigint "trip_location_id"
    t.index ["trip_location_id"], name: "index_notifications_on_trip_location_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "body"
    t.integer "privacy", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "requests_to_join", force: :cascade do |t|
    t.bigint "trip_location_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_location_id", "user_id"], name: "index_requests_to_join_on_trip_location_id_and_user_id", unique: true
    t.index ["trip_location_id"], name: "index_requests_to_join_on_trip_location_id"
    t.index ["user_id"], name: "index_requests_to_join_on_user_id"
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration"
    t.string "apn_key"
    t.string "apn_key_id"
    t.string "team_id"
    t.string "bundle_id"
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string "device_token", limit: 64, null: false
    t.datetime "failed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer "badge"
    t.string "device_token", limit: 64
    t.string "sound"
    t.text "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at"
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at"
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alert_is_json", default: false, null: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids"
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after"
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.boolean "content_available", default: false, null: false
    t.text "notification"
    t.boolean "mutable_content", default: false, null: false
    t.string "external_device_id"
    t.index ["delivered", "failed", "processing", "deliver_after", "created_at"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))"
  end

  create_table "travels", force: :cascade do |t|
    t.string "name", null: false
    t.string "reservation_number"
    t.string "airline"
    t.string "flight_number"
    t.string "description"
    t.bigint "departure_location_id"
    t.string "departure_airport"
    t.date "departing_at", null: false
    t.bigint "arrival_location_id"
    t.string "arrival_airport"
    t.date "arriving_at", null: false
    t.bigint "trip_location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "departing_at_time"
    t.string "arriving_at_time"
    t.integer "user_id"
    t.index ["arrival_location_id"], name: "index_travels_on_arrival_location_id"
    t.index ["departure_location_id"], name: "index_travels_on_departure_location_id"
    t.index ["trip_location_id"], name: "index_travels_on_trip_location_id"
  end

  create_table "trip_location_invitations", force: :cascade do |t|
    t.bigint "trip_location_id", null: false
    t.bigint "sender_user_id", null: false
    t.bigint "recipient_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_user_id"], name: "index_trip_location_invitations_on_recipient_user_id"
    t.index ["sender_user_id"], name: "index_trip_location_invitations_on_sender_user_id"
    t.index ["trip_location_id", "sender_user_id", "recipient_user_id"], name: "unique_invitations", unique: true
    t.index ["trip_location_id"], name: "index_trip_location_invitations_on_trip_location_id"
  end

  create_table "trip_location_participants", force: :cascade do |t|
    t.bigint "trip_location_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_location_id", "user_id"], name: "unique_participants", unique: true
    t.index ["trip_location_id"], name: "index_trip_location_participants_on_trip_location_id"
    t.index ["user_id"], name: "index_trip_location_participants_on_user_id"
  end

  create_table "trip_locations", id: :serial, force: :cascade do |t|
    t.integer "trip_id", null: false
    t.integer "location_id", null: false
    t.date "start_at", null: false
    t.date "end_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_trip_locations_on_location_id"
    t.index ["trip_id"], name: "index_trip_locations_on_trip_id"
  end

  create_table "trips", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "name"
    t.text "description"
    t.string "privacy_settings", default: "FriendsOfFriends", null: false
    t.string "can_invite", default: "MyNetwork", null: false
  end

  create_table "user_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "salt"
    t.string "provider"
    t.string "uid"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "raw_data"
    t.string "raw_data_sha"
    t.integer "hometown_id"
    t.integer "location_id"
    t.string "picture"
    t.string "slug"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string "fb_image"
    t.bigint "phone_number"
    t.string "website"
    t.datetime "last_sign_out_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.text "bio"
    t.string "quote"
    t.date "date_of_birth"
    t.string "role"
    t.integer "viewed_walkthrough"
    t.boolean "account_created", default: false
    t.string "twitter_id"
    t.string "facebook_id"
    t.string "instagram_id"
    t.string "linked_in_id"
    t.string "youtube_id"
    t.string "blog_id"
    t.string "current_step"
    t.boolean "exclude_analytics", default: false
    t.integer "location_privacy", default: 3, null: false
    t.string "jwt_token"
    t.string "ios_device_token"
    t.string "android_device_token"
    t.string "device_type"
    t.float "vs"
    t.string "signup_source"
    t.float "app_version"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "votable_id"
    t.string "votable_type"
    t.integer "voter_id"
    t.string "voter_type"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
  end

  create_table "waitlists", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "referred_by"
    t.string "referral_link"
    t.integer "position"
    t.string "name"
    t.string "uid"
  end

  create_table "whitelists", id: :serial, force: :cascade do |t|
    t.string "event"
    t.string "uuid"
    t.string "email"
    t.string "name"
    t.string "safe_name"
    t.integer "position"
    t.string "affiliate"
    t.date "activated_at"
    t.string "activation_code"
    t.string "referred_count"
    t.string "responses"
    t.date "created_at"
    t.string "referred_by"
  end

  add_foreign_key "accommodations", "locations"
  add_foreign_key "accommodations", "trip_locations"
  add_foreign_key "comments", "users"
  add_foreign_key "community_privacy_settings", "communities"
  add_foreign_key "events", "trip_locations"
  add_foreign_key "friend_requests", "users", column: "recipient_user_id"
  add_foreign_key "friend_requests", "users", column: "sender_user_id"
  add_foreign_key "friendships", "users", column: "destination_user_id"
  add_foreign_key "friendships", "users", column: "origin_user_id"
  add_foreign_key "images", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "requests_to_join", "trip_locations"
  add_foreign_key "requests_to_join", "users"
  add_foreign_key "travels", "locations", column: "arrival_location_id"
  add_foreign_key "travels", "locations", column: "departure_location_id"
  add_foreign_key "travels", "trip_locations"
  add_foreign_key "trip_location_invitations", "trip_locations"
  add_foreign_key "trip_location_invitations", "users", column: "recipient_user_id"
  add_foreign_key "trip_location_invitations", "users", column: "sender_user_id"
  add_foreign_key "trip_location_participants", "trip_locations"
  add_foreign_key "trip_location_participants", "users"
  add_foreign_key "trip_locations", "locations"
  add_foreign_key "trip_locations", "trips"
  add_foreign_key "user_settings", "users"
end
