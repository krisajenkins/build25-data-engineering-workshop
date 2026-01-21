-- Select the account, warehouse, and database you are using
use role accountadmin;
use warehouse compute_wh;
use database analytics_db;

-- Create a dynamic table for customers table
create or replace dynamic table stg_customers_dt
    target_lag=downstream
    warehouse=compute_wh
    as select 
        custid as customer_id,
        cname as customer_name,
        cast(spendlimit as float) as spend_limit
    from raw_db.public.customers;

-- Display what type of data and example data in the orders table
desc table raw_db.public.orders;
select* from raw_db.public.orders;

-- Create a dynamic table for orders table
create or replace dynamic table stg_orders_dt
    target_lag=downstream
    warehouse=compute_wh
    as select
        custid as customer_id,
        purchase:"prodid"::number(5) as product_id,
        purchase:"purchase_amount"::float(10) as order_price,
        purchase:"quantity"::number(5) as quantity,
        purchase:"purchase_date"::date as order_date
    from raw_db.public.orders;

-- Query the new DT that you created
select * from analytics_db.public.stg_customers_dt;
select * from analytics_db.public.stg_orders_dt;

-- Create a fact dynamic table for customer orders
create or replace dynamic table fct_customer_orders_dt
    target_lag=downstream
    warehouse=compute_wh
    as select 
        c.customer_id,
        c.customer_name,
        o.product_id,
        o.order_price,
        o.quantity,
        o.order_date
    from stg_customers_dt c
    left join stg_orders_dt o
        on c.customer_id = o.customer_id;

-- Query the new Fact DT that you created
select * from analytics_db.public.fct_customer_orders_dt;

-- Displays all the dynamic tables that we have created
show dynamic tables;
