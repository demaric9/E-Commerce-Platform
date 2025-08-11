{{ config(materialized='table', tags=['mart']) }}

with int_order_payments as (
    select * from {{ ref('int_payments') }}
)

select
    op.order_id,
    d.order_key,
    op.payment_type,
    op.payment_installments,
    op.payment_value
from int_order_payments op
join {{ ref('dim_order') }} d using(order_id)