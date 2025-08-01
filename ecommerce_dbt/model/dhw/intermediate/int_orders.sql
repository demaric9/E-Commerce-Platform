{{ config(materialized='ephemeral')}}

with orders as (
    select * from {{ ref('stg_order') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
),

order_items as (
    select * from {{ ref('stg_order') }}
),

enriched_order as (
    select 
        order_id,
        customer_id,
        order_status,

        date(order_purchase_timestamp) as order_date,
        extract(year from order_purchase_timestamp) as order_year,
        extract(month from order_purchase_timestamp) as order_month,

        sum(product_price) as total_product_value,
        sum(shipping_fee) as total_shipping_value,
        sum(product_price + shipping_fee) as total_order_value,
        count(*) as total_items,
        count(distinct product_id) as unique_product,
        count(distinct seller_id) as unique_seller,

        case when customer_delivered_time is not null
            then date_diff(customer_delivered_time, order_purchase_timestamp, day)
        end as delivery_days,

        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state

    from orders o
    left join order_items oi using(order_id)
    left join customers c using(customer_id)
    group by order_id, customer_id, order_status, order_purchase_timestamp,
             c.customer_zip_code_prefix, c.customer_city, c.customer_state
)

select * from enriched_order