with
    countries as (
        select *
        from {{ source("order_platform", "countries") }}
    ),
    final as (
        select 
            *,
        from countries
    )
select *
from final
