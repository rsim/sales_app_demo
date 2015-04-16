class Dwh::CustomerDimension < Dwh::Dimension

  def self.load!
    truncate!
    column_names = %w(id full_name city state_province country birth_date gender
      created_at updated_at)
    connection.insert %[
      INSERT INTO #{table_name} (#{column_names.join(',')})
      SELECT #{column_names.join(',')}
      FROM #{::Customer.table_name}
    ]
  end

end
