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

ActiveRecord::Schema.define(version: 2019_05_24_144823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.string "description"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.string "contact_email"
  end

  create_table "company_item_tags", force: :cascade do |t|
    t.integer "company_item_id"
    t.integer "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_items", force: :cascade do |t|
    t.integer "company_id"
    t.string "image"
    t.string "name"
    t.string "price"
    t.string "link_to_store"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forgot_password_attempts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "attempts_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "startup_news", force: :cascade do |t|
    t.integer "company_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
  end

  create_table "users", force: :cascade do |t|
    t.integer "role"
    t.string "name"
    t.string "surname"
    t.string "email"
    t.string "password"
    t.string "goals"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_email_notifications_available", default: false
    t.string "phone"
  end

end
