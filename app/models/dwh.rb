require 'mondrian-olap'

module Dwh

  def self.load_dimensions!
    CustomerDimension.load!
    ProductDimension.load!
    TimeDimension.load!
  end

  def self.load_facts!
    SalesFact.load!
  end

  def self.schema
    Mondrian::OLAP::Schema.define do
      description "Generated at #{Time.now.to_s(:db)}"
      cube 'Sales' do
        table 'f_sales', schema: 'dwh'

        dimension 'Customer', foreign_key: 'customer_id' do
          hierarchy all_member_name: 'All Customers', primary_key: 'id' do
            table 'd_customers', schema: 'dwh'
            level 'Country', column: 'country'
            level 'State Province', column: 'state_province'
            level 'City', column: 'city'
            level 'Name', column: 'full_name'
          end
        end

        dimension 'Gender', foreign_key: 'customer_id' do
          hierarchy all_member_name: 'All Genders', primary_key: 'id' do
            table 'd_customers', schema: 'dwh'
            level 'Gender', column: 'gender' do
              name_expression do
                sql "CASE d_customers.gender
                     WHEN 'F' THEN 'Female'
                     WHEN 'M' THEN 'Male'
                     END"
              end
            end
          end
        end

        dimension 'Age interval', foreign_key: 'customer_id' do
          hierarchy all_member_name: 'All Age', primary_key: 'id' do
            table 'd_customers', schema: 'dwh'
            level 'Age interval' do
              key_expression do
                sql "CASE
                     WHEN age(d_customers.birth_date) < interval '20 years'
                     THEN '< 20 years'
                     WHEN age(d_customers.birth_date) < interval '30 years'
                     THEN '20-30 years'
                     WHEN age(d_customers.birth_date) < interval '40 years'
                     THEN '30-40 years'
                     WHEN age(d_customers.birth_date) < interval '50 years'
                     THEN '40-50 years'
                     ELSE '50+ years'
                     END"
              end
            end
          end
        end

        dimension 'Product', foreign_key: 'product_id' do
          hierarchy all_member_name: 'All Products', primary_key: 'id', primary_key_table: 'd_products' do
            join left_key: 'product_class_id', right_key: 'id' do
              table 'd_products', schema: 'dwh'
              table 'd_product_classes', schema: 'dwh'
            end
            level 'Product Family', table: 'd_product_classes', column: 'product_family'
            level 'Product Department', table: 'd_product_classes', column: 'product_department'
            level 'Product Category', table: 'd_product_classes', column: 'product_category'
            level 'Product Subcategory', table: 'd_product_classes', column: 'product_subcategory'
            level 'Brand Name', table: 'd_products', column: 'brand_name'
            level 'Product Name', table: 'd_products', column: 'product_name'
          end
        end

        dimension 'Time', foreign_key: 'time_id', type: 'TimeDimension' do
          hierarchy all_member_name: 'All Time', primary_key: 'id' do
            table 'd_time', schema: 'dwh'
            level 'Year', column: 'year', type: 'Numeric', name_column: 'year_name', level_type: 'TimeYears'
            level 'Quarter', column: 'quarter', type: 'Numeric', name_column: 'quarter_name', level_type: 'TimeQuarters'
            level 'Month', column: 'month', type: 'Numeric', name_column: 'month_name', level_type: 'TimeMonths'
            level 'Day', column: 'day', type: 'Numeric', name_column: 'day_name', level_type: 'TimeDays'
          end
        end

        measure 'Sales Quantity', column: 'sales_quantity', aggregator: 'sum'
        measure 'Sales Amount', column: 'sales_amount', aggregator: 'sum'
        measure 'Sales Cost', column: 'sales_cost', aggregator: 'sum'
        measure 'Customers Count', column: 'customer_id', aggregator: 'distinct-count'

        calculated_member 'Profit', dimension: 'Measures', format_string: '#,##0.00',
          formula: '[Measures].[Sales Amount] - [Measures].[Sales Cost]'
        calculated_member 'Margin %', dimension: 'Measures', format_string: '#,##0.00%',
          formula: '[Measures].[Profit] / [Measures].[Sales Amount]'
      end
    end
  end

  def self.olap
    @olap ||= begin
      params = ActiveRecord::Base.configurations[Rails.env].symbolize_keys
      Mondrian::OLAP::Connection.create params.slice(:host, :database, :username, :password).merge(
        driver: params[:adapter], schema: schema
      )
    end
  end

  def self.reset_olap
    olap.try(:close)
    @olap = nil
  end

  def self.benchmark(format = nil, &block)
    query = instance_eval(&block)
    result = ActiveRecord::Base.benchmark(query.to_mdx) do
      query.execute
    end
    if format == :html
      File.open("tmp/output.html","w"){|f| f.puts "<pre>#{result.to_html(formatted: true)}</pre>"}
      system "open tmp/output.html"
    else
      result.row_names.zip(result.values)
    end
  end

end
