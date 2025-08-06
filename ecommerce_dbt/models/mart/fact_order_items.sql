{{ config(materialized='table') }}

with int_order_it as (
    select * from {{ ref('int_orders_items') }}
)

select 
    {{ dbt_utils.generate_surrogate_key(['order_id', 'item_number']) }} as order_item_key,
    cast(strftime(order_date, '%Y%m%d') as integer) as date_key,
    order_id,
    item_number,
     {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
     {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,
     {{ dbt_utils.generate_surrogate_key(['seller_id']) }} as seller_key,
    order_status,
    product_price,
    shipping_fee,
    total_item_value,
    order_date,
    estimated_date,
    delivered_date
from int_order_it