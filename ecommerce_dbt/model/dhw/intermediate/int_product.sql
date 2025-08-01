{{ config(materialized='ephemeral')}}
-- 1 row per product

with products as (
    select * from {{ ref('stg_product') }}
),
orders as (
    select * from {{ ref('stg_order') }}
),
order_items as (
    select * from {{ ref('stg_order_item') }}
),
review_agg as (
    select 
        order_id,
        avg(review_score) as avg_review_score,
        count(distinct review_id) as total_reviews
    from {{ ref('stg_order_review') }}
    group by order_id
),

enriched_product as (
    select 
        product_id,
        
        -- Product attributes
        product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm, 
        product_width_cm,
        
        -- Calculated attributes
        -- product_length_cm * product_height_cm * product_width_cm as product_volume_cm3,
        
        -- Product performance metrics
        count(distinct oi.order_id) as total_orders,
        sum(oi.price) as total_revenue,
        avg(oi.price) as avg_price,
        min(o.order_purchase_timestamp) as first_sold_date,
        max(o.order_purchase_timestamp) as last_sold_date,
        
        -- Product status
        case 
            when max(o.order_purchase_timestamp) >= date_sub(current_date(), interval 90 day) 
            then 'Active'
            else 'Inactive'
        end as product_status,
        
        -- Review metrics (if available)
        avg(r.review_score) as avg_rating,
        count(r.review_id) as total_reviews
        
    from products p
    left join order_items oi using(product_id)
    left join orders o using(order_id)
    left join review_agg r using(order_id)
    group by product_id, product_category_name, product_name_length,
             product_description_length, product_photos_qty, product_weight_g,
             product_length_cm, product_height_cm, product_width_cm
)
select * from enriched_product