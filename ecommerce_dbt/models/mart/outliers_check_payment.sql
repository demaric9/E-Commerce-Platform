{{ config(materialized='table', tags=['mart']) }}

{{ detect_outliers(ref('fact_order_payment'), 'payment_value', method='iqr') }}


-- WITH stats AS (
--     SELECT
--         percentile_cont(0.25) WITHIN GROUP (ORDER BY payment_value) AS q1,
--         percentile_cont(0.75) WITHIN GROUP (ORDER BY payment_value) AS q3
--     FROM {{ ref('fact_order_payment') }}
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
--     p.*,
--     CASE 
--         WHEN p.payment_value < b.lower_bound OR p.payment_value > b.upper_bound THEN 1
--         ELSE 0
--     END AS is_outlier_payment
-- FROM {{ ref('fact_order_payment') }} p, bounds b
