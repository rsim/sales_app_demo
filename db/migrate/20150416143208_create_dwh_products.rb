class CreateDwhProducts < ActiveRecord::Migration
  def change
    create_table "dwh.d_products" do |t|
      t.references :product_class, index: true
      t.string :brand_name
      t.string :product_name
      t.string :sku
      t.float :gross_weight
      t.float :net_weight
      t.boolean :recyclable_package
      t.float :shelf_width
      t.float :shelf_height
      t.float :shelf_depth
      t.timestamps
    end

    create_table "dwh.d_product_classes" do |t|
      t.string :product_family
      t.string :product_department
      t.string :product_category
      t.string :product_subcategory
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        add_index "dwh.d_products", [:brand_name, :product_name],
          name: "i_products_brand_product_name"
        add_index "dwh.d_product_classes",
          [:product_family, :product_department, :product_category, :product_subcategory],
          name: "i_product_classes_family_department_category_subcategory"
      end
    end

  end
end
