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

ActiveRecord::Schema.define(version: 20140820191300) do

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
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "apis", force: true do |t|
    t.string "key"
  end

  create_table "beacons", force: true do |t|
    t.integer "room_id",   null: false
    t.string  "key",       null: false
    t.string  "name"
    t.string  "room_type"
  end

  create_table "business_hours", force: true do |t|
    t.integer "venue_id",   null: false
    t.integer "day",        null: false
    t.time    "open_time",  null: false
    t.time    "close_time", null: false
  end

  create_table "favourite_venues", force: true do |t|
    t.integer "user_id"
    t.integer "venue_id"
  end

  create_table "locations", force: true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

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

  create_table "participants", force: true do |t|
    t.integer  "room_id",                                       null: false
    t.integer  "user_id",                                       null: false
    t.datetime "last_activity", default: '2014-07-30 22:35:18', null: false
    t.datetime "enter_time",    default: '2014-07-30 22:35:18', null: false
    t.integer  "temperature"
  end

  create_table "pokes", force: true do |t|
    t.integer  "poker_id"
    t.integer  "pokee_id"
    t.datetime "poked_at", default: '2014-07-30 22:35:18'
    t.boolean  "viewed",   default: false
  end

  create_table "read_notifications", force: true do |t|
    t.integer  "user_id"
    t.boolean  "before_sending_whisper_notification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "read_notifications", ["user_id"], name: "index_read_notifications_on_user_id", using: :btree

  create_table "rooms", force: true do |t|
    t.integer "venue_id"
    t.string  "name"
  end

  create_table "temperatures", force: true do |t|
    t.integer  "beacon_id"
    t.integer  "celsius"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "temperatures", ["beacon_id"], name: "index_temperatures_on_beacon_id", using: :btree

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
  end

  create_table "users", force: true do |t|
    t.date     "birthday",      null: false
    t.string   "first_name",    null: false
    t.string   "gender",        null: false
    t.string   "key",           null: false
    t.datetime "last_activity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apn_token"
    t.string   "layer_id"
  end

  add_index "users", ["key"], name: "index_users_on_key", unique: true, using: :btree

  create_table "venue_networks", force: true do |t|
    t.string   "city"
    t.integer  "area"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venues", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "longitude"
    t.float    "latitude"
    t.integer  "venue_network_id"
  end

  add_index "venues", ["email"], name: "index_venues_on_email", unique: true, using: :btree
  add_index "venues", ["reset_password_token"], name: "index_venues_on_reset_password_token", unique: true, using: :btree

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
