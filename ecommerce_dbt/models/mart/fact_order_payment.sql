{{ config(materialized='table', tags=['mart']) }}

with int_order_payments as (
    select * from {{ ref('stg_order_payment') }}
)

select
    op.order_id,
    op.payment_type,
    op.payment_installments,
    op.payment_value
from int_order_payments op