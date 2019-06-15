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

ActiveRecord::Schema.define(version: 2019_06_15_035837) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "business_addresses", force: :cascade do |t|
    t.bigint "business_id"
    t.string "unit"
    t.string "street"
    t.string "suburb"
    t.string "state"
    t.string "post_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_business_addresses_on_business_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "abn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_businesses_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.bigint "business_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_departments_on_business_id"
  end

  create_table "emails", force: :cascade do |t|
    t.string "email"
    t.boolean "primary"
    t.string "emailable_type"
    t.bigint "emailable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emailable_type", "emailable_id"], name: "index_emails_on_emailable_type_and_emailable_id"
  end

  create_table "employee_addresses", force: :cascade do |t|
    t.bigint "employee_id"
    t.string "unit"
    t.string "street"
    t.string "suburb"
    t.string "state"
    t.string "post_code"
    t.boolean "primary"
    t.boolean "mailing_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_addresses_on_employee_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "business_id"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_employees_on_business_id"
  end

  create_table "employment_periods", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "department_id"
    t.date "start_date"
    t.date "end_date"
    t.string "position"
    t.string "salary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_employment_periods_on_department_id"
    t.index ["employee_id"], name: "index_employment_periods_on_employee_id"
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.string "number"
    t.boolean "mobile"
    t.boolean "primary"
    t.string "phone_numberable_type"
    t.bigint "phone_numberable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_numberable_type", "phone_numberable_id"], name: "phone_numbers_phoneable"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "business_addresses", "businesses"
  add_foreign_key "businesses", "users"
  add_foreign_key "departments", "businesses"
  add_foreign_key "employee_addresses", "employees"
  add_foreign_key "employees", "businesses"
  add_foreign_key "employment_periods", "departments"
  add_foreign_key "employment_periods", "employees"
end
