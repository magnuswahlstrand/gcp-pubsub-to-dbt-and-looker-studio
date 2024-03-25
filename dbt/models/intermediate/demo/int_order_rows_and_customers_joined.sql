with
    customers as (
        select *
        from {{ ref("stg_demo__customers") }}
    ),
    countries as (
        select * 
        from {{ ref("stg_countries") }}
    ),
    customers_with_country as (
        select 
            c.*,
            country.name as country_name,
            country.region as country_region,
            country.sub_region as country_sub_region,
            from customers as c
        left join countries as country on c.country_code = country.alpha_2
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
            c.country_name as customer_country_name,
            c.country_region as customer_country_region,
            c.country_sub_region as customer_country_sub_region,
        from order_rows as o
        left join customers_with_country as c on o.customer_id = c.customer_id
    )
select * from customers_with_country
