class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :customer, index: true
      t.date :order_date
      t.string :status, limit: 20
      t.decimal :tax_amount, precision: 15, scale: 2
      t.decimal :total_amount, precision: 15, scale: 2
      t.decimal :due_amount, precision: 15, scale: 2
      t.timestamps
    end
  end
end
