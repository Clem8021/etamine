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

ActiveRecord::Schema[8.0].define(version: 2026_01_27_195359) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.string "recipient_email"
    t.index ["order_id"], name: "index_delivery_details_on_order_id"
  end

  create_table "message_card_products", force: :cascade do |t|
    t.bigint "message_card_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_card_id"], name: "index_message_card_products_on_message_card_id"
    t.index ["product_id", "message_card_id"], name: "index_message_card_products_on_product_id_and_message_card_id", unique: true
    t.index ["product_id"], name: "index_message_card_products_on_product_id"
  end

  create_table "message_cards", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_orders_on_archived_at"
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
    t.boolean "active", default: true, null: false
    t.json "gallery_images"
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name"
    t.string "active_job_id"
    t.text "serialized"
    t.datetime "run_at"
    t.integer "attempts", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "delivery_details", "orders", on_delete: :cascade
  add_foreign_key "message_card_products", "message_cards"
  add_foreign_key "message_card_products", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
end
