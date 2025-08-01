{{ config(materialized='ephemeral')}}

with customers as (
    select * from {{ ref('stg_customer') }}
),
orders as (
    select * from {{ ref('stg_order') }}
),
order_items as (
    select * from {{ ref('stg_order') }}
),

enriched_customer as (
    select 
        customer_id,
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
        
        -- Customer segmentation
        case 
            when count(distinct o.order_id) = 1 then 'One-time'
            when count(distinct o.order_id) between 2 and 5 then 'Regular'
            when count(distinct o.order_id) > 5 then 'Loyal'
            else 'New'
        end as customer_segment,
        
        -- Recency (days since last order)
        date_diff(current_date(), max(o.order_purchase_timestamp), day) as days_since_last_order,
        
        -- Average order value
        avg(oi.price + oi.freight_value) as avg_order_value
        
    from customers c
    left join orders o using(customer_id)
    left join order_items oi using(order_id)
    group by customer_id, customer_unique_id, customer_zip_code_prefix, 
            customer_city, customer_state
)

select * from enriched_customer