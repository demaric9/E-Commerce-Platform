{{ config(materialized='view', tags=['staging']) }}

with sources as (
    select * from {{ source('source_raw', 'olist_orders_dataset') }}
    where order_status = 'delivered'
),
stg_orders as (
    select
        cast(order_id as varchar) as order_id,
        cast(customer_id as varchar) as customer_id,
        lower(trim(order_status)) as order_status,
        cast(order_purchase_timestamp as timestamp) as order_purchase_timestamp,
        cast(order_approved_at as timestamp) as order_approved_time,
        cast(order_delivered_carrier_date as timestamp) as carrier_delivered_time,
        cast(order_delivered_customer_date as timestamp) as customer_delivered_time,
        cast(order_estimated_delivery_date as timestamp) as estimated_delivery_time
    from sources 
    where order_id is not null
)
select * from stg_orders