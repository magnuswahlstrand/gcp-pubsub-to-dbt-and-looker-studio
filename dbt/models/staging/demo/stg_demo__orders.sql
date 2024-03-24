with
    orders as (
        select *
        from {{ source("order_platform_order_created", "order_platform_table") }}
    ),
    final as (
        select * from orders
    )
select *
from final
