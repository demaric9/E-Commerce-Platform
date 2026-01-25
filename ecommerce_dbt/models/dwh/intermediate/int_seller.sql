{{ config(materialized='table', tags=['intermediate'])}}

with sellers as (
    select * from {{ ref('snapshots_seller') }}
),
enriched_seller as (
    select 
        seller_id,
        seller_zip_code,
        r.latitude,
        r.longtitude,
        r.city,
        r.state,
        seller.dbt_valid_from,
        seller.dbt_valid_to,
        seller.dbt_scd_id
    from sellers seller 
    join {{ ref('int_region') }} r
        on seller.seller_zip_code = r.geolocation_zip_code_prefix
)
select * from enriched_seller