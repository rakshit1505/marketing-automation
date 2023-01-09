# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_01_09_102228) do

  create_table "call_agendas", force: :cascade do |t|
    t.string "objective"
    t.string "description"
    t.integer "call_information_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "call_informations", force: :cascade do |t|
    t.integer "lead_id"
    t.integer "call_type_id"
    t.datetime "start_time"
    t.integer "user_id"
    t.string "call_owner"
    t.string "subject"
    t.string "reminder"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "call_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "last_name"
    t.string "website"
    t.string "social_media_handle"
    t.integer "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "deals", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "potential_id", null: false
    t.datetime "kick_off_date"
    t.datetime "sign_off_date"
    t.string "term"
    t.string "tenure"
    t.string "description"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["potential_id"], name: "index_deals_on_potential_id"
    t.index ["user_id"], name: "index_deals_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lead_addresses", force: :cascade do |t|
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "zip_code"
    t.integer "lead_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lead_ratings", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lead_sources", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "leads", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email_id"
    t.string "phone_number"
    t.string "company_id"
    t.string "title"
    t.integer "lead_source_id"
    t.integer "lead_status_id"
    t.string "industry"
    t.string "company_size"
    t.string "website"
    t.integer "address_id"
    t.integer "lead_rating_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.string "title"
    t.integer "type_of_meeting"
    t.boolean "is_online"
    t.string "duration"
    t.integer "user_id"
    t.string "description"
    t.string "reminder"
    t.string "agenda"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "lead_id"
    t.string "title"
    t.string "description"
    t.integer "attachment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "notable_type"
    t.integer "notable_id"
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable_type_and_notable_id"
  end

  create_table "potentials", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "lead_id", null: false
    t.integer "status"
    t.string "outcome"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lead_id"], name: "index_potentials_on_lead_id"
    t.index ["user_id"], name: "index_potentials_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "statusable_type"
    t.integer "statusable_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "task_owner"
    t.string "last_name"
    t.string "due_date_time"
    t.integer "priority"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "phone"
    t.integer "role_id"
    t.integer "department_id"
    t.integer "company_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "jti", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "deals", "potentials"
  add_foreign_key "deals", "users"
  add_foreign_key "leads", "users"
  add_foreign_key "potentials", "leads"
  add_foreign_key "potentials", "users"
end
