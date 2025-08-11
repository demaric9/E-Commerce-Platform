{{ config(materialized='table', tags=['mart']) }}
-- dim_order.sql
SELECT
  {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS order_key,
  order_id
FROM {{ ref('stg_order') }}
