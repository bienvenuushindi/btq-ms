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

ActiveRecord::Schema[7.0].define(version: 2023_12_07_120217) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "addresses", force: :cascade do |t|
    t.string "line1", null: false
    t.string "line2", default: ""
    t.string "city", null: false
    t.string "phone_number1", default: ""
    t.string "phone_number2", default: ""
    t.bigint "country_id", null: false
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.index ["country_id"], name: "index_addresses_on_country_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description", default: "Description"
    t.boolean "active", default: false
    t.integer "count_products", default: 0
    t.integer "parent_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_category_id"], name: "index_categories_on_parent_category_id"
  end

  create_table "categorizations", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "categorizable_type", null: false
    t.bigint "categorizable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categorizable_type", "categorizable_id"], name: "index_categorizations_on_categorizable"
    t.index ["category_id"], name: "index_categorizations_on_category_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "price_details", force: :cascade do |t|
    t.decimal "price", null: false
    t.integer "quantity_type"
    t.string "currency"
    t.bigint "supplier_id", null: false
    t.bigint "product_detail_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_detail_id"], name: "index_price_details_on_product_detail_id"
    t.index ["supplier_id", "product_detail_id", "quantity_type"], name: "index_unique_price_details", unique: true
    t.index ["supplier_id"], name: "index_price_details_on_supplier_id"
  end

  create_table "product_details", force: :cascade do |t|
    t.string "size"
    t.date "expired_date"
    t.decimal "unit_price", default: "0.0"
    t.decimal "dozen_price", default: "0.0"
    t.decimal "box_price", default: "0.0"
    t.integer "dozen_units", default: 0
    t.integer "box_units", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_id", null: false
    t.boolean "status", default: false
    t.string "currency", default: "usd"
    t.index ["product_id"], name: "index_product_details_on_product_id"
  end

  create_table "product_details_requisitions", force: :cascade do |t|
    t.boolean "found", default: false
    t.integer "quantity", default: 0
    t.integer "quantity_type"
    t.date "expired_date"
    t.decimal "price", default: "0.0"
    t.string "currency"
    t.text "note"
    t.bigint "requisition_id", null: false
    t.bigint "supplier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_detail_id", null: false
    t.index ["product_detail_id"], name: "index_product_details_requisitions_on_product_detail_id"
    t.index ["requisition_id"], name: "index_product_details_requisitions_on_requisition_id"
    t.index ["supplier_id"], name: "index_product_details_requisitions_on_supplier_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "short_description", default: "Short Description"
    t.text "description"
    t.boolean "active", default: false
    t.string "country_origin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["name"], name: "index_products_on_name"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "requisitions", force: :cascade do |t|
    t.decimal "total_price"
    t.integer "count_products", default: 0
    t.integer "count_products_bought", default: 0
    t.string "price_currency"
    t.boolean "archived"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date", default: "2023-08-09"
    t.index ["user_id"], name: "index_requisitions_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "shop_name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_suppliers_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "phone_number", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "jti", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "countries"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "price_details", "product_details"
  add_foreign_key "price_details", "suppliers"
  add_foreign_key "product_details", "products"
  add_foreign_key "product_details_requisitions", "product_details"
  add_foreign_key "product_details_requisitions", "requisitions"
  add_foreign_key "product_details_requisitions", "suppliers"
  add_foreign_key "products", "users"
  add_foreign_key "requisitions", "users"
  add_foreign_key "suppliers", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "roles"
end
