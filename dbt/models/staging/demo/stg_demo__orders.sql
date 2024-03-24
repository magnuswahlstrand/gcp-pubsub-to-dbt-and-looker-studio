with
    orders as (
        select *
        from {{ source("order_platform", "order_created") }}
    ),
    order_rows as (
        select 
            o.order_id,
            o.customer_id,
            o.order_date,
            item.item_id,
            item.quantity,
            CAST(item.price AS NUMERIC) as price,
        from orders as o, unnest(o.items) as item
    ),
    final as (
        select 
            *,
            price * quantity as line_revenue,
        from order_rows
    )
select *
from final
