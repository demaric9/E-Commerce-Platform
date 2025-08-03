{{ config(materialized='view', tags=['intermediate'])}}

with orders as (
    select * from {{ ref('stg_order') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
),

order_items as (
    select * from {{ ref('stg_order_item') }}
),
review_agg as (
    select 
        order_id,
        avg(review_score) as avg_review_score,
        count(distinct order_review_id) as total_reviews
    from {{ ref('stg_order_review') }}
    group by order_id
),
delivery_time as (
    select 
        o.order_id,
        datediff('day', order_purchase_timestamp::date, customer_delivered_time::date) as delivery_days
    from orders o
    where customer_delivered_time is not null
),

enriched_order as (
    select 
        order_id,
        customer_id,
        order_status,

        cast(o.order_purchase_timestamp as date) as order_date,
        extract(year from o.order_purchase_timestamp) as order_year,
        extract(month from o.order_purchase_timestamp) as order_month,

        sum(oi.product_price) as total_product_value,
        sum(oi.shipping_fee) as total_shipping_value,
        sum(oi.product_price + shipping_fee) as total_order_value,
        count(*) as total_items,
        count(distinct product_id) as unique_product,
        count(distinct seller_id) as unique_seller,

        d.delivery_days,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,

        r.avg_review_score,
        r.total_reviews

    from orders o
    left join order_items oi using(order_id)
    left join customers c using(customer_id)
    left join review_agg r using(order_id)
    left join delivery_time d using(order_id)
    group by order_id, customer_id, order_status, order_purchase_timestamp, d.delivery_days,
             c.customer_zip_code_prefix, c.customer_city, c.customer_state, r.avg_review_score, r.total_reviews
)

select * from enriched_order