{{ config(materialized='table', tags=['mart']) }}

WITH orders_agg AS (
    SELECT 
        order_id,
        customer_key,
        MAX(order_date) as order_date,
        COUNT(*) as total_items,
        FROM {{ ref('outliers_check_price') }}
        WHERE is_outlier = 0 AND delivery_status_check = 'ok'
        GROUP BY order_id, customer_key
),
payment_agg AS (
    SELECT 
        order_id,
        SUM(payment_value) as total_payment
        FROM {{ ref('outliers_check_payment') }}
        WHERE is_outlier = 0
        GROUP BY order_id
)
SELECT 
    c.customer_unique_id,
    o.order_id,
    o.order_date,
    p.total_payment
FROM orders_agg o 
JOIN {{ ref('dim_customer') }} c ON o.customer_key = c.customer_key
JOIN payment_agg p ON o.order_id = p.order_id