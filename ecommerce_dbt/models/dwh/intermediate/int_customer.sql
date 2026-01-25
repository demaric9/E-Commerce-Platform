{{ config(materialized='table', tags=['intermediate'])}}

with customers as (
    select *
    from {{ ref('snapshots_customer') }}
),

enriched_customer as (
    select 
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        r.latitude,
        r.longtitude,
        r.city,
        r.state,
        customer.dbt_valid_from,
        customer.dbt_valid_to,
        customer.dbt_scd_id
    from customers customer
    join {{ ref('int_region') }} r 
        on customer.customer_zip_code_prefix = r.geolocation_zip_code_prefix
)

select * from enriched_customer