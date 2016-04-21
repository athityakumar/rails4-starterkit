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

ActiveRecord::Schema.define(version: 20160415124034) do

  create_table "concierges", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "email",       limit: 255
    t.string   "company",     limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "emails", force: :cascade do |t|
    t.string   "email",      limit: 255, default: "", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "twitter_followers", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "screen_name",    limit: 255
    t.string   "twitter_id",     limit: 255
    t.boolean  "following",                  default: false
    t.boolean  "followers",                  default: false
    t.date     "date_processed"
    t.integer  "attempts",       limit: 4,   default: 0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "twitter_followers", ["screen_name"], name: "index_twitter_followers_on_screen_name", unique: true, using: :btree

  create_table "twitter_user_followers", force: :cascade do |t|
    t.integer  "twitter_user_id",     limit: 4
    t.integer  "twitter_follower_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "twitter_users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
