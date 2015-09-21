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

ActiveRecord::Schema.define(version: 20141006140435) do

  create_table "katalog_user_notes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "record_id"
    t.string   "scope_id"
    t.text     "value",      limit: 1073741823
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "katalog_user_notes", ["record_id"], name: "index_katalog_user_notes_on_record_id"
  add_index "katalog_user_notes", ["user_id"], name: "index_katalog_user_notes_on_user_id"

  create_table "katalog_user_watch_list_entries", force: :cascade do |t|
    t.string   "record_id"
    t.string   "scope_id"
    t.integer  "watch_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "katalog_user_watch_list_entries", ["watch_list_id"], name: "index_katalog_user_watch_list_entries_on_watch_list_id"

  create_table "katalog_user_watch_lists", force: :cascade do |t|
    t.text     "description"
    t.string   "name"
    t.boolean  "public",      default: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "katalog_user_watch_lists", ["user_id"], name: "index_katalog_user_watch_lists_on_user_id"

  create_table "katalog_users", force: :cascade do |t|
    t.string   "api_key"
    t.string   "scope_id"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "katalog_users", ["api_key"], name: "index_katalog_users_on_api_key", unique: true
  add_index "katalog_users", ["username"], name: "index_katalog_users_on_username"

end
