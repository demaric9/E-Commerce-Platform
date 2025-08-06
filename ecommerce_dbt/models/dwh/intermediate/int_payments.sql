{{ config(materialized='ephemeral', tags=['intermediate'])}}
-- 1 row per payment (can be multiple per order)

with payments as (
    select * from {{ ref('stg_order_payment') }}
),
enriched_payments as (
    select 
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    from payments
)
SELECT * FROM enriched_payments