{{ config(materialized='table', tags=['intermediate'])}}

with stg_order_payment as (
    select * from {{ ref('stg_order_payment') }}
)
select 
    op.order_id,
    op.payment_sequential,
    op.payment_installments,
    op.payment_type,
    op.payment_value,
    cast(o.order_purchase_timestamp as date) as order_date,
    op.loaded_at
from stg_order_payment op
join {{ ref('stg_order') }} o on op.order_id = o.order_id 