{{ config(materialized='ephemeral')}}

with orderds as (
    select * from {{ ref('stg_order') }}
),

customers as (
    select * from {{ ref('stg_customer') }}
),

products as (
    select * from {{ ref('stg_product') }}
),

order_payment_agg as (
    select
        order_id,
        count(*) as payment_count,
        sum(payment_value) as total_payment_value,
        max(payment_installments) as max_installments,
        mode() within group (order by payment_type) as primary_payment_type,
        max(case when payment_type = 'credit_card' then 1 else 0 end) as has_credit_card,
        max(case when payment_type = 'boleto' then 1 else 0 end) as has_boleto,
        max(case when payment_type = 'debit_card' then 1 else 0 end) as has_debit_card,
        max(case when payment_type = 'voucher' then 1 else 0 end) as has_voucher
    from {{ ref('stg_order_payment') }}
    group by order_id
),

order_items_agg as (
    order_id,
    count(*) as total_items,
    sum(price) as total_product_value,
    sum(freight_value) as total_freight_value,
    sum(price + freight_value) as total_order_value,
    avg(price) as avg_item_price,
    max(price) as max_item_price,
    count(distinct product_id) as unique_products,
    count(distinct seller_id) as unique_sellers
)