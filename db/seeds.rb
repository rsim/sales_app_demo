# SQLs for populating tables from foodmart database data

[
"truncate customers",
"truncate products",
"truncate product_classes",
"vacuum",

<<-SQL,
insert into customers (id, full_name, address1, address2, city, state_province, postal_code, country, birth_date, gender)
select * from dblink('dbname=foodmart',
'select customer_id, fullname, address1, address2, city, state_province, postal_code, country, birthdate, gender from customer'
) as t(id int4, full_name varchar, address1 varchar, address2 varchar, city varchar, state_province varchar,
postal_code varchar, country varchar, birth_date date, gender varchar)
SQL

<<-SQL,
insert into products (id, product_class_id, product_name, brand_name, sku, gross_weight, net_weight, recyclable_package,
shelf_width, shelf_height, shelf_depth)
select * from dblink('dbname=foodmart',
'select product_id, product_class_id, product_name, brand_name, CAST("SKU" AS varchar), gross_weight, net_weight, recyclable_package,
shelf_width, shelf_height, shelf_depth from product'
) as t(product_id int4, product_class_id int4, product_name varchar, brand_name varchar, sku varchar,
gross_weight float4, net_weight float4, recyclable_package bool, shelf_width float4, shelf_height float4, shelf_depth float4)
SQL

<<-SQL,
insert into product_classes (id, product_family, product_department, product_category, product_subcategory)
select * from dblink('dbname=foodmart',
'select product_class_id, product_family, product_department, product_category, product_subcategory from product_class'
) as t(product_class_id int4, product_family varchar, product_department varchar,
product_category varchar, product_subcategory varchar)
SQL

"drop table if exists sales_fact",
<<-SQL,
create table sales_fact (id serial, order_id int4, order_date date, customer_id int4, product_id int4,
quantity int4, amount numeric(15,2), cost numeric(15,4)
)
SQL
"create index on sales_fact (order_date, customer_id)",

2.times.map do
[

<<-SQL,
insert into sales_fact (order_date, customer_id, product_id, quantity, amount, cost)
select * from dblink('dbname=foodmart',
'select t.the_date, s.customer_id, s.product_id,
s.unit_sales, s.store_sales, s.store_cost
from sales_fact_1998 as s join time_by_day as t on t.time_id = s.time_id
union all
select t.the_date, s.customer_id, s.product_id,
s.unit_sales, s.store_sales, s.store_cost
from sales_fact_dec_1998 as s join time_by_day as t on t.time_id = s.time_id'
) as t(order_date date, customer_id int4, product_id int4,
quantity numeric(10,4), amount numeric(10,4), cost numeric(10,4))
SQL

# next years
(1..16).map do |year_count|
<<-SQL
insert into sales_fact (order_date, customer_id, product_id, quantity, amount, cost)
select order_date + interval '#{year_count} year', customer_id, product_id,
case when quantity > 1 then floor(quantity * (rand + 0.5)) else quantity end as quantity,
amount * (rand + 0.5) as amount, cost * (rand + 0.5) as cost
from dblink('dbname=foodmart',
'select t.the_date, s.customer_id, s.product_id,
s.unit_sales, s.store_sales, s.store_cost, random()
from sales_fact_1998 as s join time_by_day as t on t.time_id = s.time_id
union all
select t.the_date, s.customer_id, s.product_id,
s.unit_sales, s.store_sales, s.store_cost, random()
from sales_fact_dec_1998 as s join time_by_day as t on t.time_id = s.time_id'
) as t(order_date date, customer_id int4, product_id int4,
quantity numeric(10,4), amount numeric(10,4), cost numeric(10,4), rand float)
SQL
end

].flatten
end,

<<-SQL,
update sales_fact s
set order_id = (select min(s2.id) from sales_fact s2
where s2.order_date = s.order_date and s2.customer_id = s.customer_id)
SQL

"truncate orders",
"truncate order_items",
"vacuum",

<<-SQL,
insert into orders(id, customer_id, order_date, status, total_amount)
select order_id, customer_id, order_date, 'paid', sum(amount)
from sales_fact
group by order_id, customer_id, order_date
SQL

<<-SQL,
insert into order_items(id, order_id, product_id, position, quantity, price, amount, cost)
select id, order_id, product_id, id - order_id + 1 as position,
quantity, amount/quantity as price, amount, cost
from sales_fact
SQL

].flatten.each do |sql|

  puts "=== Executing:\n#{sql}"
  start_time = Time.now
  result = ActiveRecord::Base.connection.execute sql
  message = "=== Finished in %.3f seconds" % (Time.now - start_time)
  if result.is_a?(Integer)
    message << ", #{result} rows"
  end
  puts message
end
