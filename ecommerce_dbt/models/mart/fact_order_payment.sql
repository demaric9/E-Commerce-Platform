{{ config(materialized='table') }}

with int_order_payments as (
    select * from {{ ref('int_payments') }}
)

select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
from int_order_payments