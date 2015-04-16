class Dwh::SalesFact < Dwh::Fact
  belongs_to :customer, class_name: "Dwh::CustomerDimension"
  belongs_to :product, class_name: "Dwh::ProductDimension"
  belongs_to :time, class_name: "Dwh::TimeDimension"

  def self.load!
    truncate!

    connection.insert %[
      INSERT INTO #{table_name}
        (customer_id, product_id, time_id,
        sales_quantity, sales_amount, sales_cost)
      SELECT
        o.customer_id, oi.product_id, CAST(to_char(o.order_date, 'YYYYMMDD') AS INTEGER),
        oi.quantity, oi.amount, oi.cost
      FROM
        #{OrderItem.table_name} oi
        INNER JOIN #{Order.table_name} o ON o.id = oi.order_id
    ]
  end

end
