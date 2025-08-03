{{ config(materialized='view') }}

with sources as (
    select * from {{ source('source_raw', 'olist_order_payments_dataset') }}
), 
stg_order_payments as (
    select
        cast(order_id as varchar) as order_id,
        cast(payment_sequential as integer) as payment_sequential,
        cast(payment_type as varchar) as payment_type,
        cast(payment_installments as integer) as payment_installments,
        cast(payment_value as double) as payment_value
    from sources
    where order_id is not null
)
select * from stg_order_payments