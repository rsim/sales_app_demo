class CreateDwhSales < ActiveRecord::Migration
  def change
    create_table "dwh.f_sales", id: false do |t|
      t.references :customer, index: true
      t.references :product, index: true
      t.references :time, index: true
      t.integer :sales_quantity
      t.decimal :sales_amount, precision: 15, scale: 2
      t.decimal :sales_cost, precision: 15, scale: 4
    end
  end
end
