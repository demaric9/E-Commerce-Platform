{{ config(materialized='table', tags=['intermediate'])}}

with orders as (
    select * from {{ ref('stg_order') }}
),

enriched_order_items as (
    select 
        order_id,
        item_number,
        o.customer_id,
        product_id,
        seller_id,
        order_status,
        oi.product_price,
        oi.shipping_fee,
        oi.product_price + oi.shipping_fee as total_item_value,
        cast(o.estimated_delivery_time as date) as estimated_date,
        cast(o.order_purchase_timestamp as date) as order_date,
        cast(o.customer_delivered_time as date) as delivered_date,
        case 
            when order_status = 'delivered' and delivered_date is null then 'missing'
            when order_status = 'delivered' and delivered_date is not null then 'ok'
            else 'not_applicable'
        end as delivery_status_check,
        oi.loaded_at


    from {{ ref('stg_order_item') }} oi 
    left join orders o using(order_id)
)

select * from enriched_order_items