with
    products as (
        select *
        from {{ ref("stg_demo__products") }}
    ),
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
    final as (
        select
            o.*,
            c.name as customer_name,
            c.country_code as customer_country_code,
            c.city as customer_city,
            c.country_name as customer_country_name,
            c.country_region as customer_country_region,
            c.country_sub_region as customer_country_sub_region,
            p.id as product_id,
            p.name as product_name,
            p.type as product_type,
        from 
            order_rows as o
        left join customers_with_country as c on o.customer_id = c.customer_id
        left join products as p on o.item_id = p.id       
    )
select * from final
