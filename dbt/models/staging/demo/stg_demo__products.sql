with
    products as (
        select *
        from {{ source("order_platform", "product_created") }}
    ),
    final as (
        select 
            id,
            name,
            type,
        from products
    )
select *
from final
