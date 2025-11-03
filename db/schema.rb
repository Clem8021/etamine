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

ActiveRecord::Schema[8.0].define(version: 2025_11_03_192402) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "delivery_details", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "mode"
    t.date "date"
    t.string "day"
    t.string "time_slot"
    t.text "ceremony_info"
    t.string "recipient_name"
    t.string "recipient_firstname"
    t.string "recipient_address"
    t.string "recipient_zip"
    t.string "recipient_city"
    t.string "recipient_phone"
    t.string "sender_name"
    t.string "sender_phone"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "ceremony_date"
    t.time "ceremony_time"
    t.string "ceremony_location"
    t.index ["order_id"], name: "index_delivery_details_on_order_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.integer "price_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
    t.string "size"
    t.text "addon_text"
    t.string "addon_type"
    t.boolean "message_card"
    t.text "message_text"
    t.boolean "ribbon"
    t.text "ribbon_text"
    t.text "addons", default: [], array: true
    t.string "addon_card_type"
    t.text "addon_card_text"
    t.text "addon_ruban_text"
    t.boolean "addon_card", default: false, null: false
    t.boolean "addon_ruban", default: false, null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "full_name"
    t.text "address"
    t.string "email"
    t.string "status", default: "pending"
    t.integer "total_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "price_cents"
    t.string "category"
    t.string "image_url"
    t.integer "stock_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "customizable_price"
    t.integer "min_price_cents"
    t.jsonb "color_options"
    t.string "size_options"
    t.string "addons"
    t.string "product_type"
    t.jsonb "price_options", default: {}
    t.string "variety"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "delivery_details", "orders"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
end
