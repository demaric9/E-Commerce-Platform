{{ config(materialized='table', tags=['mart']) }}

with base as (
    select
        oi.order_id,
        oi.seller_key,
        s.region_key,
        oi.date_key,
        oi.order_date,
        oi.delivered_date,
        oi.estimated_date
    from {{ ref('fact_order_items') }} oi
    left join {{ ref('dim_seller') }} s 
        on oi.seller_key = s.seller_key
),

agg as (
    select
        date_key,
        seller_key,
        region_key,
        count(distinct order_id) as orders_processed,
        avg(
            datediff(
                'day',
                order_date,
                delivered_date
            )
        ) as avg_delivery_time_days,

        count(case when delivered_date is not null
                    and delivered_date <= estimated_date then 1 end)::float
        / nullif(count(case when delivered_date is not null then 1 end),0) 
            as on_time_delivery_rate

    from base
    group by date_key, seller_key, region_key
)

select 
    date_key,
    seller_key,
    region_key,
    orders_processed,
    avg_delivery_time_days,
    on_time_delivery_rate
from agg
