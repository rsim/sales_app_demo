class Dwh::TimeDimension < Dwh::Dimension

  def self.load!
  has_many :sales_facts, class_name: "Dwh::SalesFact", foreign_key: "time_id"
    connection.select_values(%[
      SELECT DISTINCT order_date FROM #{Order.table_name}
      WHERE order_date NOT IN (SELECT date_value FROM #{table_name})
    ]).each do |date|
      year, month, day = date.year, date.month, date.day
      quarter = ((month-1)/3)+1
      quarter_name = "Q#{quarter} #{year}"
      month_name = date.strftime("%b %Y")
      day_name = date.strftime("%b %d %Y")

      sql = send :sanitize_sql_array, [
        %[
          INSERT INTO #{table_name}
          (id, date_value, year, quarter, month, day,
          year_name, quarter_name, month_name, day_name)
          VALUES
          (?, ?, ?, ?, ?, ?,
          ?, ?, ?, ?)
        ],
        date_to_id(date), date, year, quarter, month, day,
        year.to_s, quarter_name, month_name, day_name
      ]

      connection.insert sql
    end
  end

  def self.date_to_id(date)
    date && date.strftime("%Y%m%d").to_i
  end

end
