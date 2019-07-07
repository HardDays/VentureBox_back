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

ActiveRecord::Schema.define(version: 2019_07_07_120059) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "company_name"
    t.string "website"
    t.string "description"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_email"
    t.integer "stage_of_funding"
    t.integer "investment_amount"
    t.integer "equality_amount"
  end

  create_table "company_images", force: :cascade do |t|
    t.integer "company_id"
    t.string "base64"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_item_images", force: :cascade do |t|
    t.integer "company_item_id"
    t.string "base64"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_item_tags", force: :cascade do |t|
    t.integer "company_item_id"
    t.integer "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_items", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "price"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "country_id"
    t.string "product_type"
  end

  create_table "company_team_members", force: :cascade do |t|
    t.integer "company_id"
    t.string "team_member_name"
    t.integer "c_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forgot_password_attempts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "attempts_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interesting_companies", force: :cascade do |t|
    t.integer "investor_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invested_companies", force: :cascade do |t|
    t.integer "investor_id"
    t.integer "company_id"
    t.string "contact_email"
    t.integer "investment"
    t.integer "evaluation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_from"
    t.datetime "date_to"
  end

  create_table "milestones", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "finish_date"
    t.integer "completeness", default: 0
    t.integer "company_id"
    t.boolean "is_done", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resized_company_images", force: :cascade do |t|
    t.integer "company_image_id"
    t.string "base64"
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resized_company_item_images", force: :cascade do |t|
    t.integer "company_item_image_id"
    t.string "base64"
    t.integer "width"
    t.integer "height"
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
    t.string "access_token"
    t.string "refresh_token"
    t.string "google_calendar_id"
  end

end
