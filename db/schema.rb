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

ActiveRecord::Schema.define(version: 2020_05_21_225958) do

  create_table "alma_fees", force: :cascade do |t|
    t.string "fee_id"
    t.string "fee_type"
    t.string "fee_description"
    t.string "fee_status"
    t.string "user_primary_id"
    t.float "balance"
    t.float "remaining_vat_amount"
    t.float "original_amount"
    t.float "original_vat_amount"
    t.datetime "creation_time"
    t.datetime "status_time"
    t.string "owner_id"
    t.string "owner_description"
    t.text "item_title"
    t.string "item_barcode"
    t.string "yorku_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["fee_id", "yorku_id"], name: "index_alma_fees_on_fee_id_and_yorku_id"
    t.index ["fee_id"], name: "index_alma_fees_on_fee_id", unique: true
  end

  create_table "payment_records", force: :cascade do |t|
    t.integer "fee_id"
    t.integer "user_id"
    t.integer "transaction_id"
    t.string "yorku_id"
    t.string "alma_fee_id"
    t.float "amount"
    t.string "status"
    t.text "payment_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "alma_fines_paid_at"
    t.datetime "alma_fines_rejected_at"
    t.string "alma_fines_rejected_error_reason"
    t.string "alma_fines_rejected_error_code"
    t.string "alma_fines_rejected_error_tracking_id"
    t.string "fee_owner_id"
    t.string "fee_owner_description"
    t.text "fee_item_title"
    t.string "fee_item_barcode"
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.string "uid"
    t.integer "user_id"
    t.string "yorku_id"
    t.string "status"
    t.string "order_id"
    t.string "message"
    t.string "cardtype"
    t.float "amount"
    t.string "authcode"
    t.string "refnum"
    t.string "txn_num"
    t.string "cardholder"
    t.string "cardnum"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "yporderid"
    t.datetime "alma_fines_paid_at"
    t.datetime "ypb_transaction_approved_at"
    t.datetime "ypb_transaction_declined_at"
    t.string "library_id"
  end

  create_table "transaction_logs", force: :cascade do |t|
    t.string "yorku_id"
    t.string "alma_fee_id"
    t.integer "transaction_id"
    t.string "ypb_transaction_id"
    t.datetime "logged_at"
    t.string "process_name"
    t.text "message"
    t.text "additional_changes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transaction_id"], name: "index_transaction_logs_on_transaction_id"
    t.index ["yorku_id"], name: "index_transaction_logs_on_yorku_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password"
    t.string "role"
    t.string "level"
    t.string "yorku_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "became_admin_at"
    t.index ["yorku_id"], name: "index_users_on_yorku_id", unique: true
  end

end
