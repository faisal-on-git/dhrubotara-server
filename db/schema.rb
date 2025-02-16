# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_02_15_221929) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "account_type"
    t.decimal "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category", default: "asset", null: false
    t.boolean "active", default: true, null: false
  end

  create_table "budgets", force: :cascade do |t|
    t.string "category"
    t.decimal "budgeted"
    t.decimal "spent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.date "date"
    t.string "description"
    t.decimal "amount"
    t.string "transaction_type"
    t.string "category"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "transfer_account_id"
    t.bigint "budget_id"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["budget_id"], name: "index_transactions_on_budget_id"
    t.index ["transfer_account_id"], name: "index_transactions_on_transfer_account_id"
  end

  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "accounts", column: "transfer_account_id"
  add_foreign_key "transactions", "budgets"
end
