{{ config(
    materialized = 'incremental',
    unique_key = 'order_payment_key',
    incremental_strategy = 'delete+insert',
    tags=['mart']
) }}

with int_order_payments as (
    select * from {{ ref('int_order_payment') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['order_id', 'payment_sequential']) }} as order_payment_key,
    cast(strftime(order_date, '%Y%m%d') as integer) as date_key,
    op.order_id,
    op.payment_sequential,
    op.payment_type,
    op.payment_installments,
    op.payment_value,
    op.order_date,
    loaded_at
from int_order_payments op

{% if is_incremental() %}
  where loaded_at > (select max(loaded_at) from {{ this }})
{% endif %}
