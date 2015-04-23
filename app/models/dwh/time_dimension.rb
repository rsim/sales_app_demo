require 'concurrent/executors'

class Dwh::TimeDimension < Dwh::Dimension
  has_many :sales_facts, class_name: "Dwh::SalesFact", foreign_key: "time_id"

  def self.load!
    logger.silence do
      connection.select_values(%[
        SELECT DISTINCT order_date FROM #{Order.table_name}
        WHERE order_date NOT IN (SELECT date_value FROM #{table_name})
      ]).each do |date|
        insert_date(date)
      end
    end
  end

  def self.parallel_load!(pool_size = 4)
    logger.silence do
      insert_date_pool = Concurrent::FixedThreadPool.new(pool_size)

      connection.select_values(%[
        SELECT DISTINCT order_date FROM #{Order.table_name}
        WHERE order_date NOT IN (SELECT date_value FROM #{table_name})
      ]).each do |date|
        insert_date_pool.post(date) do |date|
          connection_pool.with_connection do
            insert_date(date)
          end
        end
      end

      insert_date_pool.shutdown
      insert_date_pool.wait_for_termination
    end
  end

  def self.date_to_id(date)
    date && date.strftime("%Y%m%d").to_i
  end

  private

  def self.insert_date(date)
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
