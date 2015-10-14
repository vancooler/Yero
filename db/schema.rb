# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151013180000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "active_in_venue_networks", force: true do |t|
    t.integer  "venue_network_id",                                 null: false
    t.integer  "user_id",                                          null: false
    t.datetime "last_activity",    default: '2014-09-05 19:48:39', null: false
    t.datetime "enter_time",       default: '2014-09-05 19:48:39', null: false
    t.integer  "active_status",    default: 1
  end

  create_table "active_in_venues", force: true do |t|
    t.integer  "venue_id",                                      null: false
    t.integer  "user_id",                                       null: false
    t.datetime "last_activity", default: '2014-09-05 19:26:31', null: false
    t.datetime "enter_time",    default: '2014-09-05 19:26:31', null: false
    t.integer  "beacon_id"
  end

  create_table "activities", force: true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "since_1970"
  end

  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "apis", force: true do |t|
    t.string "key"
  end

  create_table "beacons", force: true do |t|
    t.string  "key",      null: false
    t.string  "name"
    t.integer "venue_id"
  end

  create_table "beta_signup_users", force: true do |t|
    t.string   "email",       null: false
    t.string   "city"
    t.string   "phone_model"
    t.string   "phone_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "block_users", force: true do |t|
    t.integer  "target_user_id", null: false
    t.integer  "origin_user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "block_users", ["target_user_id", "origin_user_id"], name: "index_block_users_on_target_user_id_and_origin_user_id", using: :btree

  create_table "business_hours", force: true do |t|
    t.integer "venue_id",   null: false
    t.integer "day",        null: false
    t.time    "open_time",  null: false
    t.time    "close_time", null: false
  end

  create_table "city_networks", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "early_venues", force: true do |t|
    t.string   "username"
    t.string   "city"
    t.string   "job_title"
    t.string   "phone"
    t.string   "email"
    t.string   "venue_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favourite_venues", force: true do |t|
    t.integer "user_id"
    t.integer "venue_id"
  end

  create_table "follows", force: true do |t|
    t.string   "follower_type"
    t.integer  "follower_id"
    t.string   "followable_type"
    t.integer  "followable_id"
    t.datetime "created_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "friend_by_whispers", force: true do |t|
    t.integer  "target_user_id",                                 null: false
    t.integer  "origin_user_id",                                 null: false
    t.datetime "friend_time",    default: '2015-07-24 20:45:56', null: false
    t.boolean  "viewed"
  end

  create_table "global_variables", force: true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "greeting_messages", force: true do |t|
    t.integer  "weekday_id"
    t.integer  "venue_id"
    t.string   "first_dj"
    t.string   "second_dj"
    t.string   "last_call"
    t.float    "admission_fee"
    t.string   "drink_special"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "draft_pending",         default: false
    t.string   "pending_second_dj"
    t.string   "pending_first_dj"
    t.string   "pending_last_call"
    t.float    "pending_admission_fee"
    t.string   "pending_drink_special"
    t.text     "pending_description"
    t.string   "last_call_as"
    t.string   "pending_last_call_as"
  end

  add_index "greeting_messages", ["venue_id"], name: "index_greeting_messages_on_venue_id", using: :btree

  create_table "greeting_posters", force: true do |t|
    t.integer  "greeting_message_id"
    t.string   "avatar"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", force: true do |t|
    t.string   "liker_type"
    t.integer  "liker_id"
    t.string   "likeable_type"
    t.integer  "likeable_id"
    t.datetime "created_at"
  end

  add_index "likes", ["likeable_id", "likeable_type"], name: "fk_likeables", using: :btree
  add_index "likes", ["liker_id", "liker_type"], name: "fk_likes", using: :btree

  create_table "locations", force: true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "mentions", force: true do |t|
    t.string   "mentioner_type"
    t.integer  "mentioner_id"
    t.string   "mentionable_type"
    t.integer  "mentionable_id"
    t.datetime "created_at"
  end

  add_index "mentions", ["mentionable_id", "mentionable_type"], name: "fk_mentionables", using: :btree
  add_index "mentions", ["mentioner_id", "mentioner_type"], name: "fk_mentions", using: :btree

  create_table "nightlies", force: true do |t|
    t.integer  "venue_id",                      null: false
    t.integer  "girl_count",        default: 0
    t.integer  "boy_count",         default: 0
    t.integer  "guest_wait_time",   default: 0
    t.integer  "regular_wait_time", default: 0
    t.integer  "current_fill",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notification_preferences", force: true do |t|
    t.string   "name",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default_value"
  end

  add_index "notification_preferences", ["name"], name: "index_notification_preferences_on_name", unique: true, using: :btree

  create_table "participants", force: true do |t|
    t.integer  "room_id",                                       null: false
    t.integer  "user_id",                                       null: false
    t.datetime "last_activity", default: '2014-09-02 20:49:09', null: false
    t.datetime "enter_time",    default: '2014-09-02 20:49:09', null: false
    t.integer  "temperature"
  end

  create_table "pokes", force: true do |t|
    t.integer  "poker_id"
    t.integer  "pokee_id"
    t.datetime "poked_at", default: '2014-09-02 20:49:09'
    t.boolean  "viewed",   default: false
  end

  create_table "preset_greeting_images", force: true do |t|
    t.integer  "greeting_message_id"
    t.string   "avatar"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default_template",    default: false
  end

  create_table "prospect_city_clients", force: true do |t|
    t.string   "email"
    t.float    "longitude"
    t.float    "latitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "read_notifications", force: true do |t|
    t.integer  "user_id"
    t.boolean  "before_sending_whisper_notification", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "read_notifications", ["user_id"], name: "index_read_notifications_on_user_id", using: :btree

  create_table "recent_activities", force: true do |t|
    t.integer  "target_user_id",   null: false
    t.integer  "origin_user_id"
    t.integer  "venue_id"
    t.string   "activity_type",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dynamo_id"
    t.text     "message"
    t.string   "contentable_type"
    t.integer  "contentable_id"
  end

  add_index "recent_activities", ["target_user_id"], name: "index_recent_activities_on_target_user_id", using: :btree

  create_table "report_types", force: true do |t|
    t.string   "report_type_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_user_histories", force: true do |t|
    t.integer  "reporting_user_id"
    t.integer  "reported_user_id"
    t.integer  "report_type_id"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "frequency"
    t.datetime "notified_at"
  end

  create_table "reported_users", force: true do |t|
    t.string   "first_name"
    t.string   "key"
    t.string   "apn_token"
    t.string   "email"
    t.integer  "count"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reported_users", ["user_id"], name: "index_reported_users_on_user_id", using: :btree

  create_table "rooms", force: true do |t|
    t.integer "venue_id"
    t.string  "name"
  end

  create_table "share_histories", force: true do |t|
    t.integer  "share_reference_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "share_references", force: true do |t|
    t.string   "name",       null: false
    t.integer  "count",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shout_comment_votes", force: true do |t|
    t.integer  "shout_comment_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "upvote"
  end

  add_index "shout_comment_votes", ["shout_comment_id"], name: "index_shout_comment_votes_on_shout_comment_id", using: :btree

  create_table "shout_comments", force: true do |t|
    t.text     "body"
    t.integer  "shout_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "venue_id"
  end

  add_index "shout_comments", ["shout_id"], name: "index_shout_comments_on_shout_id", using: :btree
  add_index "shout_comments", ["user_id"], name: "index_shout_comments_on_user_id", using: :btree

  create_table "shout_report_histories", force: true do |t|
    t.integer  "shout_report_type_id"
    t.text     "reason"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.integer  "reporter_id"
    t.integer  "frequency"
    t.datetime "solved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shout_report_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shout_votes", force: true do |t|
    t.integer  "shout_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "upvote"
  end

  add_index "shout_votes", ["shout_id"], name: "index_shout_votes_on_shout_id", using: :btree

  create_table "shouts", force: true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_nearby"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "venue_id"
  end

  add_index "shouts", ["user_id"], name: "index_shouts_on_user_id", using: :btree

  create_table "temperatures", force: true do |t|
    t.integer  "beacon_id"
    t.integer  "celsius"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "temperatures", ["beacon_id"], name: "index_temperatures_on_beacon_id", using: :btree

  create_table "time_zone_places", force: true do |t|
    t.string   "timezone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_no_active"
  end

  create_table "traffics", force: true do |t|
    t.integer "room_id",   null: false
    t.integer "beacon_id", null: false
    t.integer "user_id",   null: false
    t.string  "location",  null: false
  end

  create_table "user_avatars", force: true do |t|
    t.integer  "user_id"
    t.string   "avatar"
    t.boolean  "default",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "processing"
    t.boolean  "image_processed"
    t.boolean  "avatar_processing"
    t.boolean  "is_active",         default: true
    t.string   "avatar_tmp"
    t.integer  "order"
    t.text     "origin_url"
    t.text     "thumb_url"
  end

  create_table "user_notification_preferences", force: true do |t|
    t.integer  "notification_preference_id", null: false
    t.integer  "user_id",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.date     "birthday",                                                              null: false
    t.string   "first_name",                                                            null: false
    t.string   "gender",                                                                null: false
    t.string   "key",                                                                   null: false
    t.datetime "last_activity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apn_token"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "last_active"
    t.string   "introduction_1",                        default: " "
    t.string   "introduction_2",                        default: " "
    t.integer  "notification_read"
    t.string   "email"
    t.string   "snapchat_id"
    t.string   "wechat_id"
    t.boolean  "discovery",                             default: true
    t.boolean  "exclusive",                             default: false
    t.boolean  "active",                                default: true
    t.boolean  "accept_contract",                       default: false
    t.string   "instagram_id"
    t.string   "password_digest"
    t.integer  "account_status"
    t.boolean  "is_connected",                          default: false
    t.boolean  "enough_user_notification_sent_tonight", default: false
    t.datetime "key_expiration"
    t.string   "line_id"
    t.string   "password_reset_token"
    t.integer  "avatar_disabled_count"
    t.string   "timezone_name"
    t.string   "email_reset_token"
    t.string   "current_venue"
    t.string   "current_city"
    t.boolean  "fake_user",                             default: false
    t.string   "instagram_token"
    t.datetime "last_status_active_time",               default: '2015-09-03 21:26:18'
    t.string   "spotify_id"
    t.string   "spotify_token"
    t.string   "version"
    t.boolean  "pusher_private_online",                 default: false
    t.string   "username"
    t.integer  "point",                                 default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "venue_avatars", force: true do |t|
    t.integer  "venue_id"
    t.string   "avatar"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venue_entered_todays", force: true do |t|
    t.integer  "venue_id",                                   null: false
    t.integer  "user_id",                                    null: false
    t.datetime "enter_time", default: '2014-09-19 01:04:34', null: false
  end

  create_table "venue_entries", force: true do |t|
    t.integer  "venue_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venue_entries", ["venue_id"], name: "index_venue_entries_on_venue_id", using: :btree

  create_table "venue_logos", force: true do |t|
    t.integer  "venue_id"
    t.string   "avatar"
    t.boolean  "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venue_networks", force: true do |t|
    t.string   "city"
    t.integer  "area"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone"
  end

  create_table "venue_pictures", force: true do |t|
    t.string   "pic_location"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venue_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venues", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "address_line_one"
    t.string   "address_line_two"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "dress_code"
    t.integer  "age_requirement"
    t.string   "venue_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "longitude"
    t.float    "latitude"
    t.integer  "venue_network_id"
    t.integer  "web_user_id"
    t.string   "manager_first_name"
    t.string   "manager_last_name"
    t.string   "manager_phone"
    t.string   "pending_manager_first_name"
    t.string   "pending_manager_last_name"
    t.string   "pending_manager_phone"
    t.string   "pending_name"
    t.string   "pending_phone"
    t.string   "pending_email"
    t.integer  "pending_venue_type_id"
    t.integer  "pending_venue_network_id"
    t.string   "pending_address"
    t.string   "pending_city"
    t.string   "pending_state"
    t.string   "pending_country"
    t.string   "pending_zipcode"
    t.float    "pending_latitude"
    t.float    "pending_longitude"
    t.boolean  "draft_pending",              default: false
    t.boolean  "featured",                   default: false
    t.integer  "featured_order"
    t.string   "timezone",                   default: "America/Vancouver"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "unlock_number"
  end

  add_index "venues", ["venue_type_id"], name: "index_venues_on_venue_type_id", using: :btree
  add_index "venues", ["web_user_id"], name: "index_venues_on_web_user_id", using: :btree

  create_table "web_users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "business_name"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zipcode"
    t.string   "business_phone"
    t.string   "cell_phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "web_user_name"
    t.string   "job_title"
    t.string   "venue_name"
  end

  add_index "web_users", ["email"], name: "index_web_users_on_email", unique: true, using: :btree
  add_index "web_users", ["reset_password_token"], name: "index_web_users_on_reset_password_token", unique: true, using: :btree

  create_table "weekdays", force: true do |t|
    t.string "weekday_title"
  end

  create_table "whisper_replies", force: true do |t|
    t.integer  "speaker_id", null: false
    t.integer  "whisper_id", null: false
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "whisper_replies", ["whisper_id"], name: "index_whisper_replies_on_whisper_id", using: :btree

  create_table "whisper_sents", force: true do |t|
    t.integer  "target_user_id",                                 null: false
    t.integer  "origin_user_id",                                 null: false
    t.datetime "whisper_time",   default: '2014-09-25 23:02:29', null: false
    t.integer  "paper_owner_id"
  end

  create_table "whisper_todays", force: true do |t|
    t.integer  "target_user_id",                 null: false
    t.integer  "origin_user_id"
    t.integer  "venue_id"
    t.integer  "whisper_type",                   null: false
    t.boolean  "viewed",         default: false
    t.boolean  "accepted",       default: false
    t.boolean  "declined",       default: false
    t.text     "message",        default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dynamo_id"
    t.integer  "paper_owner_id"
    t.text     "message_b"
  end

  add_index "whisper_todays", ["target_user_id"], name: "index_whisper_todays_on_target_user_id", using: :btree

  create_table "whispers", force: true do |t|
    t.integer  "origin_id"
    t.integer  "target_id"
    t.boolean  "viewed",     default: false
    t.boolean  "accepted",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "whispers", ["origin_id"], name: "index_whispers_on_origin_id", using: :btree
  add_index "whispers", ["target_id"], name: "index_whispers_on_target_id", using: :btree

  create_table "winners", force: true do |t|
    t.integer  "user_id",                    null: false
    t.string   "message",                    null: false
    t.integer  "venue_id",                   null: false
    t.boolean  "claimed",    default: false
    t.string   "winner_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
