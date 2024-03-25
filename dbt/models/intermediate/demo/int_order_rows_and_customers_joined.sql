with
    customers as (
        select *
        from {{ ref("stg_demo__customers") }}
    ),
    order_rows as (
        select * 
        from {{ ref("stg_demo__orders") }}
    ),
    rows_with_customers as (
        select 
            o.*,
            c.country_code as customer_country_code,
            c.city as customer_city,
            c.name as customer_name,
        from order_rows as o
        left join customers as c on o.customer_id = c.customer_id
    )
select * from rows_with_customers