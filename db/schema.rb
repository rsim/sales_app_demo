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

ActiveRecord::Schema.define(version: 20150415143452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string   "full_name",      limit: 255
    t.string   "address1",       limit: 255
    t.string   "address2",       limit: 255
    t.string   "city",           limit: 255
    t.string   "state_province", limit: 255
    t.string   "postal_code",    limit: 255
    t.string   "country",        limit: 255
    t.date     "birth_date"
    t.string   "gender",         limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "position"
    t.integer  "quantity"
    t.decimal  "price",      precision: 15, scale: 4
    t.decimal  "amount",     precision: 15, scale: 2
    t.decimal  "cost",       precision: 15, scale: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "customer_id"
    t.date     "order_date"
    t.string   "status",       limit: 20
    t.decimal  "tax_amount",              precision: 15, scale: 2
    t.decimal  "total_amount",            precision: 15, scale: 2
    t.decimal  "due_amount",              precision: 15, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["customer_id"], name: "index_orders_on_customer_id", using: :btree

  create_table "product_classes", force: :cascade do |t|
    t.string   "product_family",      limit: 255
    t.string   "product_department",  limit: 255
    t.string   "product_category",    limit: 255
    t.string   "product_subcategory", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.integer  "product_class_id"
    t.string   "product_name",      limit: 255
    t.string   "brand_name",        limit: 255
    t.string   "sku",               limit: 255
    t.float    "gross_weight"
    t.float    "net_weight"
    t.boolean  "recyclable_package"
    t.float    "shelf_width"
    t.float    "shelf_height"
    t.float    "shelf_depth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["product_class_id"], name: "index_products_on_product_class_id", using: :btree

end
