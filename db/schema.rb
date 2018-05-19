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

ActiveRecord::Schema.define(version: 20180517031340) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "announcements", force: :cascade do |t|
    t.integer "user_id"
    t.integer "release_id"
    t.string "title"
    t.text "text"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "old_id"
    t.string "image_uri"
  end

  create_table "artist_infos", force: :cascade do |t|
    t.string "bio_short"
    t.text "bio_long"
    t.string "facebook"
    t.string "twitter"
    t.string "instagram"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "genre"
    t.integer "followers_count", default: 0
    t.integer "tracks_count", default: 0
  end

  create_table "average_caches", force: :cascade do |t|
    t.bigint "rater_id"
    t.string "rateable_type"
    t.bigint "rateable_id"
    t.float "avg", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rateable_type", "rateable_id"], name: "index_average_caches_on_rateable_type_and_rateable_id"
    t.index ["rater_id"], name: "index_average_caches_on_rater_id"
  end

  create_table "badge_action_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "badge_kind_id"
    t.integer "points"
    t.integer "count_to_achieve", default: 1
  end

  create_table "badge_dependencies", force: :cascade do |t|
    t.integer "badge_id"
    t.integer "depended_badge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badge_kinds", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badge_levels", force: :cascade do |t|
    t.integer "badge_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "notified", default: false
    t.index ["badge_id", "user_id"], name: "index_badge_levels_on_badge_id_and_user_id", unique: true
  end

  create_table "badge_points", force: :cascade do |t|
    t.integer "user_id"
    t.integer "badge_kind_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "badge_id"
    t.integer "accumulated_count"
    t.integer "badge_action_type_id"
    t.datetime "accumulated_at"
  end

  create_table "badge_points_weights", force: :cascade do |t|
    t.integer "badge_id"
    t.integer "badge_action_type_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "condition"
    t.boolean "active", default: false
    t.index ["badge_id", "badge_action_type_id"], name: "index_badge_points_weights_on_badge_id_and_badge_action_type_id", unique: true
  end

  create_table "badges", force: :cascade do |t|
    t.string "name"
    t.integer "points"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.integer "badge_kind_id"
    t.string "message"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.text "body"
    t.integer "user_id"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "likes_count", default: 0
    t.integer "replies_count", default: 0
    t.integer "shares_count", default: 0
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "downloads", force: :cascade do |t|
    t.bigint "track_id"
    t.bigint "user_id"
    t.integer "format"
    t.boolean "release", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_downloads_on_track_id"
    t.index ["user_id"], name: "index_downloads_on_user_id"
  end

  create_table "emails", force: :cascade do |t|
    t.string "subject", null: false
    t.text "body_html"
    t.text "body_text"
    t.string "from", null: false
    t.string "image_uri"
    t.string "title"
    t.string "cta_link"
    t.string "cta_text"
    t.string "template", null: false
    t.string "category"
    t.string "batch_id"
    t.datetime "send_at", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emails_users", force: :cascade do |t|
    t.bigint "email_id"
    t.bigint "user_id"
    t.index ["email_id"], name: "index_emails_users_on_email_id"
    t.index ["user_id"], name: "index_emails_users_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.integer "user_id"
    t.integer "followable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "followable_type"
    t.index ["followable_id"], name: "index_follows_on_followable_id"
    t.index ["user_id", "followable_id", "followable_type"], name: "index_follows_on_user_id_and_followable_id_and_followable_type", unique: true
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "likeable_id"
    t.string "likeable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "likeable_id", "likeable_type"], name: "index_likes_on_user_id_and_likeable_id_and_likeable_type", unique: true
  end

  create_table "meta_tags", force: :cascade do |t|
    t.string "meta_tags"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_meta_tags_on_resource_type_and_resource_id"
  end

  create_table "overall_averages", force: :cascade do |t|
    t.string "rateable_type"
    t.bigint "rateable_id"
    t.float "overall_avg", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rateable_type", "rateable_id"], name: "index_overall_averages_on_rateable_type_and_rateable_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.integer "user_id"
    t.string "tracks"
    t.string "current_track"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.string "image_url"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "topic_id"
    t.integer "user_id"
    t.integer "parent_id"
    t.integer "replies_count", default: 0
  end

  create_table "rates", force: :cascade do |t|
    t.bigint "rater_id"
    t.string "rateable_type"
    t.bigint "rateable_id"
    t.float "stars", null: false
    t.string "dimension"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rateable_type", "rateable_id"], name: "index_rates_on_rateable_type_and_rateable_id"
    t.index ["rater_id"], name: "index_rates_on_rater_id"
  end

  create_table "rating_caches", force: :cascade do |t|
    t.string "cacheable_type"
    t.bigint "cacheable_id"
    t.float "avg", null: false
    t.integer "qty", null: false
    t.string "dimension"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cacheable_id", "cacheable_type"], name: "index_rating_caches_on_cacheable_id_and_cacheable_type"
    t.index ["cacheable_type", "cacheable_id"], name: "index_rating_caches_on_cacheable_type_and_cacheable_id"
  end

  create_table "release_files", force: :cascade do |t|
    t.bigint "release_id"
    t.integer "format"
    t.string "s3_bucket"
    t.string "s3_key"
    t.integer "encode_status", default: 0, null: false
    t.string "encode_job_id"
    t.datetime "deleted_at"
    t.datetime "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["datetime"], name: "index_release_files_on_datetime"
    t.index ["deleted_at"], name: "index_release_files_on_deleted_at"
    t.index ["release_id"], name: "index_release_files_on_release_id"
  end

  create_table "releases", force: :cascade do |t|
    t.string "title"
    t.string "catalog"
    t.text "text"
    t.string "avatar"
    t.string "facebook_img"
    t.datetime "published_at"
    t.string "upc_code"
    t.boolean "compilation"
    t.datetime "release_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "available_to_all"
    t.integer "old_id"
    t.boolean "drip_source"
    t.string "image_uri"
  end

  create_table "releases_users", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "release_id"
    t.index ["release_id"], name: "index_releases_users_on_release_id"
    t.index ["user_id"], name: "index_releases_users_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "site_settings", force: :cascade do |t|
    t.string "ident"
    t.string "val"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "slider_images", force: :cascade do |t|
    t.string "image"
    t.integer "priority"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topic_categories", force: :cascade do |t|
    t.string "title"
    t.integer "prior", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
  end

  create_table "topic_category_groups", force: :cascade do |t|
    t.string "title"
    t.integer "prior", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
  end

  create_table "topic_tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topic_tags_topics", force: :cascade do |t|
    t.bigint "topic_id"
    t.bigint "topic_tag_id"
    t.index ["topic_id"], name: "index_topic_tags_topics_on_topic_id"
    t.index ["topic_tag_id"], name: "index_topic_tags_topics_on_topic_tag_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.integer "user_id"
    t.boolean "pinned"
    t.boolean "locked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_id"
    t.integer "old_id"
  end

  create_table "track_files", force: :cascade do |t|
    t.bigint "track_id"
    t.integer "format"
    t.string "s3_bucket"
    t.string "s3_key"
    t.integer "encode_status", default: 0, null: false
    t.string "encode_job_id"
    t.datetime "deleted_at"
    t.datetime "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["datetime"], name: "index_track_files_on_datetime"
    t.index ["deleted_at"], name: "index_track_files_on_deleted_at"
    t.index ["track_id"], name: "index_track_files_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.integer "release_id"
    t.integer "track_number"
    t.string "genre"
    t.string "isrc_code"
    t.string "sample_uri"
    t.string "waveform_image_uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.integer "old_id"
    t.boolean "drip_source"
    t.string "artist"
  end

  create_table "tracks_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "track_id"
    t.index ["track_id"], name: "index_tracks_users_on_track_id"
    t.index ["user_id"], name: "index_tracks_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.string "first_name"
    t.string "avatar"
    t.string "braintree_customer_id"
    t.string "shipping_address"
    t.datetime "birthdate"
    t.integer "gender"
    t.string "t_shirt_size"
    t.integer "subscription_type"
    t.string "provider"
    t.string "uid"
    t.datetime "subscription_started_at"
    t.string "city"
    t.string "last_name"
    t.integer "old_id"
    t.boolean "drip_source"
    t.string "image_uri"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "videos", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.string "video_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0
    t.integer "shares_count", default: 0
  end

end
