{{ config(materialized='ephemeral', enabled=false)}}
-- 1 row per payment (can be multiple per order)
with orders as (
    select * from {{ ref('stg_order') }}
),
payments as (
    select * from {{ ref('stg_order_payment') }}
),
enriched_payments as (
    select 
        {{ dbt_utils.generate_surrogate_key(['order_id', 'payment_sequential']) }} as payment_key,
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value,
        
        -- Link to order date
        o.order_purchase_timestamp,
        date(o.order_purchase_timestamp) as payment_date
        
    from payments p
    left join orders o using(order_id)
)
SELECT * FROM enriched_payments