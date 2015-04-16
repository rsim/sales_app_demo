class Dwh::ProductDimension < Dwh::Dimension
  belongs_to :product_class, class_name: "Dwh::ProductClassDimension"

  def self.load!
    Dwh::ProductClassDimension.load!

    truncate!
    column_names = %w(id product_class_id brand_name product_name sku
      gross_weight net_weight recyclable_package shelf_width shelf_height shelf_depth
      created_at updated_at)

    connection.insert %[
      INSERT INTO #{table_name} (#{column_names.join(',')})
      SELECT #{column_names.join(',')}
      FROM #{Product.table_name}
    ]
  end

end
