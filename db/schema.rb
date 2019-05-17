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

ActiveRecord::Schema.define(version: 20190517064601) do

  create_table "cache_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "key"
    t.text "value", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_cache_entries_on_key"
  end

  create_table "notes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.string "record_id"
    t.text "value", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scope_id"
    t.index ["record_id"], name: "index_notes_on_record_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "permalinks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "key", null: false
    t.string "scope", null: false
    t.text "search_request", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_resolved_at"
    t.index ["key"], name: "index_permalinks_on_key"
  end

  create_table "server_responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "request_hash", limit: 4294967295
    t.text "data", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_hash"], name: "index_server_responses_on_request_hash", length: { request_hash: 200 }
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email_address"
    t.date "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ilsusername"
    t.string "pseudonym"
    t.string "api_key"
    t.string "password_reset_token"
    t.datetime "password_reset_token_created_at"
    t.string "ilsuserid"
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["ilsuserid"], name: "index_users_on_ilsuserid", unique: true
    t.index ["ilsusername"], name: "index_users_on_ilsusername", unique: true
    t.index ["pseudonym"], name: "index_users_on_pseudonym", unique: true
  end

  create_table "watch_list_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "watch_list_id"
    t.string "record_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scope_id", null: false
    t.index ["record_id"], name: "index_watch_list_entries_on_record_id"
    t.index ["scope_id"], name: "index_watch_list_entries_on_scope_id"
    t.index ["watch_list_id"], name: "index_watch_list_entries_on_watch_list_id"
  end

  create_table "watch_lists", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.string "name"
    t.text "description", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_watch_lists_on_user_id"
  end

end
