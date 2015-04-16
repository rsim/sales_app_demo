class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :product_class, index: true
      t.string :product_name
      t.string :brand_name
      t.string :sku
      t.float :gross_weight
      t.float :net_weight
      t.boolean :recyclable_package
      t.float :shelf_width
      t.float :shelf_height
      t.float :shelf_depth
      t.timestamps
    end
  end
end
