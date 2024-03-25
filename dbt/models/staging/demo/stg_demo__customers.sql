with
    customers as (
        select *
        from {{ source("order_platform", "customer_created") }}
    ),
    final as (
        select 
            customer_id,
            name,
            address.city as city,
            address.country as country_code,
        from customers
    )
select *
from final
