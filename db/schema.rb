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

ActiveRecord::Schema.define(version: 20140415200407) do

  create_table "requests", force: true do |t|
    t.string   "name"
    t.string   "requester"
    t.string   "requester_email"
    t.date     "date"
    t.time     "start_time"
    t.time     "end_time"
    t.string   "sponsor"
    t.string   "cost"
    t.boolean  "discount"
    t.string   "discount_owner"
    t.text     "description"
    t.text     "url"
    t.boolean  "approved",        default: false
    t.boolean  "reviewed",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group"
    t.string   "umbcusername"
    t.string   "displayName"
    t.string   "umbcDepartment"
    t.string   "mail"
  end

end
