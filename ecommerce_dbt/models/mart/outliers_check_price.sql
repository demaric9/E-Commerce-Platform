{{ config(materialized='table', tags=['mart']) }}

{{ detect_outliers(ref('fact_order_items'), 'product_price', method='iqr') }}

-- WITH stats AS (
--     SELECT
--         percentile_cont(0.25) WITHIN GROUP (ORDER BY product_price) AS q1,
--         percentile_cont(0.75) WITHIN GROUP (ORDER BY product_price) AS q3
--     FROM {{ ref('fact_order_items') }}
-- ),
-- bounds AS (
--     SELECT
--         q1,
--         q3,
--         q3 - q1 AS iqr,
--         q1 - 1.5 * (q3 - q1) AS lower_bound,
--         q3 + 1.5 * (q3 - q1) AS upper_bound
--     FROM stats
-- )
-- SELECT
--     i.*,
--     CASE 
--         WHEN i.product_price < b.lower_bound OR i.product_price > b.upper_bound THEN 1
--         ELSE 0
--     END AS is_outlier_price
-- FROM {{ ref('fact_order_items') }} i, bounds b