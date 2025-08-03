{{ config(materialized='ephemeral', enabled=false)}}
-- 1 row per seller
with orders as (
    select * from {{ ref('stg_order') }}
),
order_items as (
    select * from {{ ref('stg_order_item') }}
),
sellers as (
    select * from {{ ref('stg_seller') }}
)
enriched_seller as (
    select 
        seller_id,
        
        -- Geographic attributes
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        
        -- Seller performance metrics
        count(distinct oi.order_id) as total_orders,
        count(distinct oi.product_id) as total_products_sold,
        sum(oi.price) as total_revenue,
        avg(oi.price) as avg_item_price,
        
        -- Time-based metrics
        min(o.order_purchase_timestamp) as first_sale_date,
        max(o.order_purchase_timestamp) as last_sale_date,
        
        -- Delivery performance
        avg(case when o.order_delivered_customer_date is not null 
                then date_diff(o.order_delivered_customer_date, o.order_purchase_timestamp, day)
            end) as avg_delivery_days,
            
        -- Review performance
        avg(r.review_score) as avg_seller_rating,
        count(r.review_id) as total_reviews_received,
        
        -- Seller status
        case 
            when max(o.order_purchase_timestamp) >= date_sub(current_date(), interval 90 day)
            then 'Active'
            else 'Inactive' 
        end as seller_status
        
    from sellers s
    left join order_items oi using(seller_id)
    left join orders o using(order_id) 
    left join stg_order_reviews r using(order_id)
    group by seller_id, seller_zip_code_prefix, seller_city, seller_state
)
select * from enriched_seller