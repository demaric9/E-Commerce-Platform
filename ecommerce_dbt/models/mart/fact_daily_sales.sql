{{ config(materialized='table', tags=['mart']) }}

WITH order_items as (
    SELECT 
        oi.order_id,
        oi.date_key,
        oi.seller_key,
        oi.product_key,
        r.region_key,
        oi.product_price,
        oi.shipping_fee,
        oi.total_item_value
    FROM {{ ref('fact_order_items') }} oi 
    JOIN {{ ref('dim_product') }} p ON oi.product_key = p.product_key
    JOIN {{ ref('dim_seller') }} s ON oi.seller_key = s.seller_key
    JOIN {{ ref('dim_date') }} d ON oi.date_key = d.date_key
    JOIN {{ ref('dim_region') }} r ON r.region_key = s.region_key
)

SELECT 
    oi.date_key,
    oi.product_key,
    oi.seller_key,
    oi.region_key,
    count(distinct oi.order_id) as total_orders,
    count(*) as total_items_sold,
    sum(oi.total_item_value) as total_revenue,
    sum(oi.shipping_fee) as total_freight,
    case 
        when count(distinct oi.order_id) = 0 then 0
        else sum(oi.product_price + oi.shipping_fee) / count(distinct oi.order_id)
    end as avg_order_value
FROM order_items oi 
GROUP BY oi.date_key, oi.product_key, oi.seller_key, oi.region_key
