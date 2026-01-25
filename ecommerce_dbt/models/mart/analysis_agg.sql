{{ config(materialized='table', tags=['mart']) }}
WITH base as (
	SELECT 
		o.order_id,
		o.order_date,
		o.customer_key,
		o.seller_key,
		o.product_price,
		o.shipping_fee,
		o.product_key,
		p.product_category_name_english,
		p.weight_g,
		p.length_cm,
		p.height_cm,
		p.width_cm
	FROM {{ ref('outliers_check_price') }} o
	JOIN {{ ref('dim_product') }} p ON o.product_key = p.product_key
    WHERE o.is_outlier = 0 AND o.delivery_status_check = 'ok'
),
orders as (
	select 
		b.order_id,
		MIN(b.order_date) as order_date,
		SUM(b.product_price) as order_revenue,
		SUM(b.shipping_fee) as freight_value,
		COUNT(DISTINCT b.product_category_name_english) as num_categories,
		AVG(b.weight_g) as avg_weight,
		AVG(b.length_cm) as avg_length,
		AVG(b.height_cm) as avg_height,
		AVG(b.width_cm) as avg_width,
		
		c.state,
		
		count(distinct b.seller_key) as num_sellers
	FROM base b
	JOIN {{ ref('dim_customer') }} c ON b.customer_key = c.customer_key
	JOIN {{ ref('dim_seller') }} s ON b.seller_key = s.seller_key
	GROUP BY b.order_id, c.state
),
payments as (
	SELECT 
		order_id,
		SUM(payment_value) as total_payment,
		AVG(payment_installments) as avg_installments
	FROM {{ ref('outliers_check_payment') }}
    WHERE is_outlier = 0
	GROUP BY order_id
),
reviews as (
	SELECT 
		order_id,
		AVG(review_score) as avg_review_score
	FROM {{ ref('fact_order_reviews') }}
	GROUP BY order_id
)
SELECT 
	o.order_id,
	o.order_date,
	EXTRACT(MONTH FROM o.order_date) AS order_month,
    EXTRACT(DOW FROM o.order_date) AS day_of_week,
    
    o.order_revenue,
    o.freight_value,
    o.num_categories,
    o.avg_weight,
    o.avg_length,
    o.avg_height,
    o.avg_width,
    o.state,
    o.num_sellers,
    r.avg_review_score,
    p.total_payment,
    p.avg_installments
    
FROM orders o 
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id