{{ config(materialized='view') }}

with sources as (
    select * from {{ source('source_raw', 'olist_customers_dataset') }} 
),
stg_customers as (
    select 
        customer_id,
        customer_unique_id,
        cast(customer_zip_code_prefix as varchar) as customer_zip_code_prefix,
        trim(customer_city) as customer_city,
        upper(trim(customer_state)) as customer_state,
    from sources 
    where customer_id is not null
)

select * from stg_customers