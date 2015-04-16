class Dwh::ProductClassDimension < Dwh::Dimension

  def self.load!
    truncate!
    column_names = %w(id product_family product_department product_category product_subcategory)

    connection.insert %[
      INSERT INTO #{table_name} (#{column_names.join(',')})
      SELECT #{column_names.join(',')}
      FROM #{ProductClass.table_name}
    ]
  end

end
