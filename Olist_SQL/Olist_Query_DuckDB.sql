-- 1. Revenue over Time
WITH payments AS (
    SELECT order_id,
           ROUND(SUM(payment_value), 1) AS total_payment
    FROM main_mart.fact_order_payment
    GROUP BY order_id
),
distinct_orders AS (
    SELECT DISTINCT
        order_id, order_date
    FROM main_mart.outliers_check_price
    WHERE is_outlier = 0
)
SELECT 
    EXTRACT(YEAR FROM o.order_date) AS Y,
    EXTRACT(QUARTER FROM o.order_date) AS Q,
    SUM(p.total_payment) AS TotalPayment
FROM distinct_orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY Y, Q
ORDER BY Y, Q;


-- 2. Orders over Time
SELECT
	EXTRACT(YEAR FROM order_date) as Y,
	EXTRACT(QUARTER FROM order_date) as Q,
	COUNT(DISTINCT order_id) as num_of_orders
FROM main_mart.fact_order_items
WHERE order_status = 'delivered' AND delivery_status_check = 'ok'
GROUP BY Y,Q
ORDER BY Y,Q;

SELECT COUNT(DISTINCT order_id) FROM main_mart.fact_order_items
WHERE order_status = 'delivered' AND delivery_status_check = 'ok';

-- 3. Product Revenue
WITH payments AS (
    SELECT order_id,
           ROUND(SUM(payment_value), 0)  AS total_payment
    FROM main_mart.fact_order_payment
    GROUP BY order_id
),
item_counts AS (
    SELECT order_id,
           COUNT(*) AS num_items
    FROM main_mart.outliers_check_price
    WHERE is_outlier = 0
    GROUP BY order_id
)
SELECT 
    d.product_category_name_english,
    SUM(p.total_payment / ic.num_items) AS TotalRevenue
FROM main_mart.outliers_check_price oi
JOIN main_mart.dim_product d ON d.product_key = oi.product_key
JOIN payments p ON oi.order_id = p.order_id
JOIN item_counts ic ON oi.order_id = ic.order_id
GROUP BY d.product_category_name_english
ORDER BY TotalRevenue DESC;

-- 4. AOV
WITH total_payment_on_each_order AS (
SELECT
	oi.order_id,
	SUM(oi.total_item_value) as order_value
FROM main_mart.outliers_check_price oi
WHERE oi.order_status = 'delivered' AND oi.delivery_status_check = 'ok'
GROUP BY oi.order_id
)
SELECT SUM(order_value) / COUNT(*) AS AOV
FROM total_payment_on_each_order; 

-- 5. AOV over Time
WITH order_value_over_time AS (
SELECT
	order_id,
	EXTRACT(YEAR FROM order_date) AS Y,
	EXTRACT(QUARTER FROM order_date) AS Q,
	SUM(total_item_value) as order_value
FROM main_mart.outliers_check_price 
WHERE order_status = 'delivered' AND delivery_status_check = 'ok'
GROUP BY order_id, Y, Q
ORDER BY order_id, Y, Q
)
SELECT Y,Q, AVG(order_value)
FROM order_value_over_time
GROUP BY Y,Q
ORDER BY Y,Q;


-- 6. Number of Customer Repeated Purchase (included num 0)
WITH num_repurchase_customer AS (
SELECT d.customer_unique_id,
	COUNT(*) as num_purchase
FROM main_mart.dim_customer d
GROUP BY d.customer_unique_id 
HAVING COUNT(*) >= 2
)
SELECT d.customer_unique_id,
	  COUNT(DISTINCT oi.order_id) as num_of_order
FROM main_mart.dim_customer d
JOIN num_repurchase_customer rc ON d.customer_unique_id = rc.customer_unique_id
LEFT JOIN main_mart.fact_order_items oi ON d.customer_key = oi.customer_key
GROUP BY d.customer_unique_id
ORDER BY COUNT(DISTINCT oi.order_id)



-- 7. Percentage of repeated purchase
WITH num_repurchase_customer AS (
SELECT d.customer_unique_id,
	COUNT(*) as num_purchase
FROM main_mart.dim_customer d
GROUP BY d.customer_unique_id 
HAVING COUNT(*) >= 2
),
counting_order AS (
SELECT d.customer_unique_id,
	  COUNT(DISTINCT oi.order_id) as num_of_order
FROM main_mart.dim_customer d
JOIN num_repurchase_customer rc ON d.customer_unique_id = rc.customer_unique_id
LEFT JOIN main_mart.fact_order_items oi ON d.customer_key = oi.customer_key
GROUP BY d.customer_unique_id
ORDER BY COUNT(DISTINCT oi.order_id)
),
total_customer AS (  
SELECT
	COUNT(DISTINCT customer_unique_id) as total_cus
	FROM main_mart.dim_customer
)
SELECT COUNT(c.customer_unique_id) as total_repeated,
	   ROUND(COUNT(c.customer_unique_id) * 100.0 / ANY_VALUE(t.total_cus), 2) as pct
FROM counting_order c
CROSS JOIN total_customer t
WHERE num_of_order >= 2;

-- 8. Avg Review Score
SELECT
	AVG(review_score)
FROM main_mart.fact_order_reviews;

-- Order by Review Score
SELECT review_score,
	   COUNT(DISTINCT order_id) AS num_of_orders
FROM main_mart.fact_order_reviews
GROUP BY review_score
ORDER BY review_score DESC;

-- Avg Review Score over Time
with agg_reviews AS (
SELECT
	order_id,
	AVG(review_score) as agg_avg_score
FROM main_mart.fact_order_reviews
GROUP BY order_id
)
SELECT
	EXTRACT(YEAR FROM oi.order_date) as Y,
	EXTRACT(QUARTER FROM oi.order_date) as Q,
	AVG(r.agg_avg_score) as score
FROM main_mart.fact_order_items oi
JOIN agg_reviews r ON oi.order_id = r.order_id
GROUP BY Y, Q
ORDER BY Y,Q;


-- 9. Payment Method
SELECT 
	payment_type,
	COUNT(DISTINCT order_id) as num_of_orders
FROM main_mart.fact_order_payment
GROUP BY payment_type;

