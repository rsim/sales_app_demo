CREATE TABLE dwh.d_customers (id INTEGER, country CHARACTER VARYING(255), state_province CHARACTER VARYING(255), city CHARACTER VARYING(255), full_name CHARACTER VARYING(255), birth_date DATE, gender CHARACTER VARYING(10), created_at TIMESTAMP(6) WITHOUT TIME ZONE, updated_at TIMESTAMP(6) WITHOUT TIME ZONE, PRIMARY KEY (id));

CREATE TABLE dwh.d_product_classes (id INTEGER, product_family CHARACTER VARYING(255), product_department CHARACTER VARYING(255), product_category CHARACTER VARYING(255), product_subcategory CHARACTER VARYING(255), created_at TIMESTAMP(6) WITHOUT TIME ZONE, updated_at TIMESTAMP(6) WITHOUT TIME ZONE, PRIMARY KEY (id));

CREATE TABLE dwh.d_products (id INTEGER, product_class_id INTEGER, brand_name CHARACTER VARYING(255), product_name CHARACTER VARYING(255), sku CHARACTER VARYING(255), gross_weight DOUBLE PRECISION, net_weight DOUBLE PRECISION, recyclable_package BOOLEAN, shelf_width DOUBLE PRECISION, shelf_height DOUBLE PRECISION, shelf_depth DOUBLE PRECISION, created_at TIMESTAMP(6) WITHOUT TIME ZONE, updated_at TIMESTAMP(6) WITHOUT TIME ZONE, PRIMARY KEY (id));

CREATE TABLE dwh.d_time (id INTEGER, date_value DATE, year INTEGER, quarter INTEGER, month INTEGER, day INTEGER, year_name CHARACTER VARYING(255), quarter_name CHARACTER VARYING(255), month_name CHARACTER VARYING(255), day_name CHARACTER VARYING(255), PRIMARY KEY (id));

CREATE TABLE dwh.f_sales (customer_id INTEGER, product_id INTEGER, time_id INTEGER, sales_quantity INTEGER, sales_amount NUMERIC(15,2), sales_cost NUMERIC(15,4));
