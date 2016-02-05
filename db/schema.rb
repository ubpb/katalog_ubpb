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

ActiveRecord::Schema.define(version: 20160205123111) do

  create_table "cache_entries", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.text     "value",      limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cache_entries", ["key"], name: "index_cache_entries_on_key", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "record_id",  limit: 255
    t.text     "value",      limit: 4294967295
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "scope_id",   limit: 255
  end

  add_index "notes", ["record_id"], name: "index_notes_on_record_id", using: :btree
  add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree

  create_table "server_responses", force: :cascade do |t|
    t.text     "request_hash", limit: 4294967295
    t.text     "data",         limit: 4294967295
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "server_responses", ["request_hash"], name: "index_server_responses_on_request_hash", length: {"request_hash"=>200}, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.string   "email_address", limit: 255
    t.date     "expiry_date"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "ilsuserid",     limit: 255
    t.string   "pseudonym",     limit: 255
    t.string   "api_key",       limit: 255
  end

  add_index "users", ["api_key"], name: "index_users_on_api_key", unique: true, using: :btree
  add_index "users", ["ilsuserid"], name: "index_users_on_ilsuserid", unique: true, using: :btree
  add_index "users", ["pseudonym"], name: "index_users_on_pseudonym", unique: true, using: :btree

  create_table "watch_list_entries", force: :cascade do |t|
    t.integer  "watch_list_id", limit: 4
    t.string   "record_id",     limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "scope_id",      limit: 255, null: false
  end

  add_index "watch_list_entries", ["record_id"], name: "index_watch_list_entries_on_record_id", using: :btree
  add_index "watch_list_entries", ["scope_id"], name: "index_watch_list_entries_on_scope_id", using: :btree
  add_index "watch_list_entries", ["watch_list_id"], name: "index_watch_list_entries_on_watch_list_id", using: :btree

  create_table "watch_lists", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "name",        limit: 255
    t.text     "description", limit: 4294967295
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "watch_lists", ["user_id"], name: "index_watch_lists_on_user_id", using: :btree

end
