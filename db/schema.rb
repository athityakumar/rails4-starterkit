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

ActiveRecord::Schema.define(version: 20160601134858) do

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

  create_table "inbound_links", force: :cascade do |t|
    t.string   "link",           limit: 255
    t.boolean  "is_processing",              default: false
    t.date     "date_processed"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "inbound_users", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "inbound_link",     limit: 255
    t.string   "twitter_link",     limit: 255
    t.string   "facebook_link",    limit: 255
    t.string   "linkedin_link",    limit: 255
    t.string   "googleplus_link",  limit: 255
    t.string   "location",         limit: 255
    t.string   "designation",      limit: 255
    t.string   "company",          limit: 255
    t.integer  "number_followers", limit: 4
    t.integer  "number_following", limit: 4
    t.integer  "number_badges",    limit: 4
    t.integer  "karma",            limit: 4
    t.text     "badges",           limit: 65535
    t.string   "recent_activity",  limit: 255
    t.boolean  "following",                      default: false
    t.boolean  "follower",                       default: false
    t.date     "date_processed"
    t.integer  "attempts",         limit: 4,     default: 0
    t.string   "image_url",        limit: 255
    t.string   "userid",           limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "company_link",     limit: 255
    t.string   "my_link",          limit: 255
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

  create_table "twitter_tweets", force: :cascade do |t|
    t.text     "tweet",        limit: 65535
    t.string   "tweet_id",     limit: 255
    t.string   "user_id",      limit: 255
    t.string   "username",     limit: 255
    t.string   "tweet_link",   limit: 255
    t.string   "profile_link", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "twitter_user_followers", force: :cascade do |t|
    t.integer  "twitter_user_id",     limit: 4
    t.integer  "twitter_follower_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "twitter_users", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "is_processing",             default: false
  end

end
