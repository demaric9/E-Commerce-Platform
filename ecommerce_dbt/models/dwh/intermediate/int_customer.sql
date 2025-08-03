{{ config(materialized='ephemeral', enabled=false)}}

with customers as (
    select * from {{ ref('stg_customer') }}
),
orders as (
    select * from {{ ref('stg_order') }}
),
order_items as (
    select * from {{ ref('stg_order_item') }}
),

enriched_customer as (
    select 
        customer_unique_id,
        
        -- Geographic 
        customer_zip_code_prefix,
        customer_city, 
        customer_state,
        
        -- Customer lifecycle metrics (from order history)
        min(o.order_purchase_timestamp) as first_order_date,
        max(o.order_purchase_timestamp) as last_order_date,
        count(distinct o.order_id) as total_lifetime_orders,
        sum(oi.price + oi.freight_value) as total_lifetime_value,
        
        -- Recency (days since last order)
        (current_date - max(o.order_purchase_timestamp)::date)::int as recency_days,
        count(distinct o.order_id) as frequency,
        sum(oi.price + oi.freight_value) as monetary_value,
        
        -- Average order value
        avg(oi.price + oi.freight_value) as avg_order_value,

        -- Total purchased items
        count(oi.order_item_id) as total_items_purchased,

        avg(oi.freight_value / nullif(oi.price, 0)) as avg_freight_rate
        
    from customers c
    left join orders o using(customer_id)
    left join order_items oi using(order_id)
    group by customer_unique_id, customer_zip_code_prefix, 
            customer_city, customer_state
)

select * from enriched_customer