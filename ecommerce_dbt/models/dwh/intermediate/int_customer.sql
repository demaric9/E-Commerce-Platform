{{ config(materialized='table', tags=['intermediate'])}}

with customers as (
    select * from {{ ref('stg_customer') }}
),

enriched_customer as (
    select 
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        r.latitude,
        r.longtitude,
        r.city,
        r.state
    from customers customer
    left join {{ ref('int_region') }} r 
        on customer.customer_zip_code_prefix = r.geolocation_zip_code_prefix
)

select * from enriched_customer