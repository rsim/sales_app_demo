Sales app
=========

Demo Sales application for Data Wareshouses and Multi-Dimensional Analysis presentation at RailsConf 2015.

Queries
-------
Get total sales amount in California in 2014 Q1 by product families

```ruby
OrderItem.joins(:order => :customer).
where("customers.country" => "USA", "customers.state_province" => "CA").
where("extract(year from orders.order_date) = ?", 2014).
where("extract(quarter from orders.order_date) = ?", 1).
joins(:product => :product_class).
group("product_classes.product_family").
sum("order_items.amount")
```

```sql
(335.0ms)
SELECT SUM(order_items.amount) AS sum_order_items_amount,
       product_classes.product_family AS product_classes_product_family
FROM "order_items"
INNER JOIN "orders" ON "orders"."id" = "order_items"."order_id"
INNER JOIN "customers" ON "customers"."id" = "orders"."customer_id"
INNER JOIN "products" ON "products"."id" = "order_items"."product_id"
INNER JOIN "product_classes" ON "product_classes"."id" = "products"."product_class_id"
WHERE "customers"."country" = 'USA'
  AND "customers"."state_province" = 'CA'
  AND (extract(YEAR FROM orders.order_date) = 2014)
  AND (extract(quarter FROM orders.order_date) = 1)
GROUP BY product_classes.product_family
```

```ruby
{
              "Food" => 61137.2,
             "Drink" => 7510.16,
    "Non-Consumable" => 16173.46
}
```

```ruby
OrderItem.joins(:order => :customer).
where("customers.country" => "USA", "customers.state_province" => "CA").
where("extract(year from orders.order_date) = ?", 2014).
where("extract(quarter from orders.order_date) = ?", 1).
joins(:product => :product_class).
group("product_classes.product_family").
select("product_classes.product_family,"+
  "SUM(order_items.amount) AS sales_amount,"+
  "SUM(order_items.cost) AS sales_cost,"+
  "COUNT(DISTINCT customers.id) AS customers_count").
map{|i| i.attributes.compact}
```

```ruby
$ rails console
>> OrderItem.count
   (677.0ms)  SELECT COUNT(*) FROM "order_items"
=> 6218022
>> Order.count
   (126.0ms)  SELECT COUNT(*) FROM "orders"
=> 642362
>> OrderItem.joins(:order => :customer).
joins(:product => :product_class).
group("product_classes.product_family").
select("product_classes.product_family,"+
  "SUM(order_items.amount) AS sales_amount,"+
  "SUM(order_items.cost) AS sales_cost,"+
  "COUNT(DISTINCT customers.id) AS customers_count").
map{|i| i.attributes.compact}

OrderItem Load (25437.0ms) ...
```

```ruby
OrderItem.joins(:order => :customer).joins(:product => :product_class).
where("customers.country" => "USA").
group("product_classes.product_family").
sum("order_items.amount")
```

```sql
(5485.0ms)
SELECT SUM(order_items.amount) AS sum_order_items_amount,
       product_classes.product_family AS product_classes_product_family
FROM "order_items"
INNER JOIN "orders" ON "orders"."id" = "order_items"."order_id"
INNER JOIN "customers" ON "customers"."id" = "orders"."customer_id"
INNER JOIN "products" ON "products"."id" = "order_items"."product_id"
INNER JOIN "product_classes" ON "product_classes"."id" = "products"."product_class_id"
WHERE "customers"."country" = 'USA'
GROUP BY product_classes.product_family
```

DWH dimension and fact tables
------------------------------

```ruby
Dwh::SalesFact.
joins(:customer).joins(:product => :product_class).joins(:time).
where("d_customers.country" => "USA", "d_customers.state_province" => "CA").
where("d_time.year" => 2014, "d_time.quarter" => 1).
group("d_product_classes.product_family").
sum("sales_amount")
```

```sql
SELECT SUM("dwh"."f_sales"."sales_amount") AS sum_sales_amount,
       d_product_classes.product_family AS d_product_classes_product_family
FROM "dwh"."f_sales"
INNER JOIN "dwh"."d_customers" ON "dwh"."d_customers"."id" = "dwh"."f_sales"."customer_id"
INNER JOIN "dwh"."d_products" ON "dwh"."d_products"."id" = "dwh"."f_sales"."product_id"
INNER JOIN "dwh"."d_product_classes" ON "dwh"."d_product_classes"."id" = "dwh"."d_products"."product_class_id"
INNER JOIN "dwh"."d_time" ON "dwh"."d_time"."id" = "dwh"."f_sales"."time_id"
WHERE "d_customers"."country" = 'USA'
  AND "d_customers"."state_province" = 'CA'
  AND "d_time"."year" = 2014
  AND "d_time"."quarter" = 1
GROUP BY d_product_classes.product_family
```

```ruby
Dwh::SalesFact.
joins(:product => :product_class).
group("d_product_classes.product_family").
select("d_product_classes.product_family,"+
  "SUM(f_sales.sales_amount) AS sales_amount,"+
  "SUM(f_sales.sales_cost) AS sales_cost,"+
  "COUNT(DISTINCT f_sales.customer_id) AS customers_count").
map{|i| i.attributes.compact}
```

```sql
(19079.0ms)
SELECT d_product_classes.product_family,
       SUM(f_sales.sales_amount) AS sales_amount,
       SUM(f_sales.sales_cost) AS sales_cost,
       COUNT(DISTINCT f_sales.customer_id) AS customers_count
FROM "dwh"."f_sales"
INNER JOIN "dwh"."d_products" ON "dwh"."d_products"."id" = "dwh"."f_sales"."product_id"
INNER JOIN "dwh"."d_product_classes" ON "dwh"."d_product_classes"."id" = "dwh"."d_products"."product_class_id"
GROUP BY d_product_classes.product_family
```

Mondrian OLAP queries
--------------------

```ruby
Dwh.benchmark {
olap.from("Sales").
columns("[Measures].[Sales Amount]").
rows("[Product].[Product Family].Members").
where("[Customer].[USA].[CA]", "[Time].[Quarter].[Q1 2014]")
}
```

```sql
SELECT {[Measures].[Sales Amount]} ON COLUMNS,
[Product].[Product Family].Members ON ROWS
FROM [Sales]
WHERE ([Customer].[USA].[CA], [Time].[Quarter].[Q1 2014])
```

```ruby
Dwh.benchmark {
olap.from("Sales").
columns("[Measures].[Sales Amount]").
rows("[Product].[Product Family].Members").
where("[Customer].[USA]")
}
```

```ruby
Dwh.benchmark {
olap.from("Sales").
columns("[Measures].[Sales Amount]",
  "[Measures].[Sales Cost]","[Measures].[Customers Count]").
rows("[Product].[Product Family].Members")
}
```

```sql
SELECT {[Measures].[Sales Amount], [Measures].[Sales Cost], [Measures].[Customers Count]} ON COLUMNS,
[Product].[Product Family].Members ON ROWS
FROM [Sales] (21713.0ms)
```

```sql
SELECT {[Measures].[Sales Amount], [Measures].[Sales Cost], [Measures].[Customers Count]} ON COLUMNS,
[Product].[Product Family].Members ON ROWS
FROM [Sales] (10.0ms)
```

```ruby
Dwh.benchmark {
olap.from("Sales").
columns("[Measures].[Sales Amount]").
rows("[Gender].[Gender].Members").
where("[Customer].[USA].[CA]", "[Time].[Quarter].[Q1 2014]")
}
```

```ruby
Dwh.benchmark(:html) {
olap.from("Sales").
columns("[Measures].[Sales Amount]").
rows("[Age interval].[Age interval].Members").
where("[Customer].[USA].[CA]", "[Time].[Quarter].[Q1 2014]")
}
```

```sql
[Age interval].[<20 years]
[Age interval].[20-30 years]
[Age interval].[30-40 years]
[Age interval].[40-50 years]
[Age interval].[50+ years]
```

```ruby
Dwh.benchmark(:html) {
olap.from("Sales").
columns("[Measures].[Profit]", "[Measures].[Margin %]").
rows("[Product].[Product Family].Members").
where("[Customer].[USA].[CA]", "[Time].[Quarter].[Q1 2014]")
}
```

Multi-threaded ETL
------------------

```ruby
Dwh::TimeDimension.load!              (5236.0ms)
Dwh::TimeDimension.parallel_load!(2)  (3450.0ms)
Dwh::TimeDimension.parallel_load!(4)  (2142.0ms)
Dwh::TimeDimension.parallel_load!(6)  (2361.0ms)
Dwh::TimeDimension.parallel_load!(8)  (2826.0ms)
```

Analytical Columnar Databases
-----------------------------

```sql
SELECT d_product_classes.product_family,
       SUM(f_sales.sales_amount) AS sales_amount,
       SUM(f_sales.sales_cost) AS sales_cost,
       COUNT(DISTINCT f_sales.customer_id) AS customers_count
FROM "dwh"."f_sales"
INNER JOIN "dwh"."d_products" ON "dwh"."d_products"."id" = "dwh"."f_sales"."product_id"
INNER JOIN "dwh"."d_product_classes" ON "dwh"."d_product_classes"."id" = "dwh"."d_products"."product_class_id"
GROUP BY d_product_classes.product_family
```

```
PostgreSQL  always ~18.5 seconds
HP Vertica  first ~9 seconds
            next ~1.5 seconds
```
