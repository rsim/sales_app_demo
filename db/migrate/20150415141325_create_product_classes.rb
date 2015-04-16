class CreateProductClasses < ActiveRecord::Migration
  def change
    create_table :product_classes do |t|
      t.string :product_family
      t.string :product_department
      t.string :product_category
      t.string :product_subcategory
      t.timestamps
    end
  end
end
