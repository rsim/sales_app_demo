class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.references :order, index: true
      t.references :product, index: true
      t.integer :position
      t.integer :quantity
      t.decimal :price, precision: 15, scale: 4
      t.decimal :amount, precision: 15, scale: 2
      t.decimal :cost, precision: 15, scale: 4
      t.timestamps
    end
  end
end
