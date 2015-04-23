class Dwh::ProductClassDimension < Dwh::Dimension
  has_many :products, class_name: "Dwh::ProductDimension", foreign_key: "product_class_id"

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
