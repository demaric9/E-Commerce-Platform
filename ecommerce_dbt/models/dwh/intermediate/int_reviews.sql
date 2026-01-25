{{ config(materialized='table', tags=['intermediate']) }}

WITH raw_reviews AS (
    SELECT * FROM {{ ref('stg_order_review') }}
),

rn_review AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY review_id
                   ORDER BY review_creation_date DESC
               ) AS rn
        FROM raw_reviews
    ) t
    WHERE rn = 1
),

rn_order AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY order_id
                   ORDER BY review_creation_date DESC
               ) AS rn
        FROM rn_review
    ) t
    WHERE rn = 1
)

SELECT
    review_id,
    order_id,
    review_score,
    CAST(review_creation_date AS date) AS review_creation_date
FROM rn_order

