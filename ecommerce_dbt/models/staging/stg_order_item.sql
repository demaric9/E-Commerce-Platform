{{ config(materialized='view', tags=['staging']) }}

with sources as (
    select * from {{ source('source_raw', 'olist_order_items_dataset') }}
), 
stg_order_items as (
    select
        cast(order_id as varchar) as order_id,
        cast(order_item_id as varchar) as item_number,
        cast(product_id as varchar) as product_id,
        cast(seller_id as varchar) as seller_id,
        cast(shipping_limit_date as timestamp) as shipping_limit_date,
        cast(price as double) as product_price,
        cast(freight_value as double) as shipping_fee
    from sources
    where order_id is not null
)
select * from stg_order_items