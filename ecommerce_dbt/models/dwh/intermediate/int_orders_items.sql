{{ config(materialized='ephemeral', enabled=false)}}

with orders as (
    select * from {{ ref('stg_order') }}
),

enriched_order_items as (
    select 
        {{ dbt_utils.generate_surrogate_key(['order_id', 'order_item_id']) }} as order_item_key

        order_id,
        product_id,
        seller_id,

        oi.product_price,
        oi.shipping_fee,
        oi.product_price + oi.shipping_fee as total_item_value

        s.seller_id,
        s.seller_state

        o.order_purchase_timestamp,
        date(o.order_purchase_timestamp) as order_date

    from {{ ref('stg_order_item') }} oi
    left join {{ ref('stg_seller') }} s using(seller_id) 
    left join orders o using(order_id)
)

select * from enriched_order_items