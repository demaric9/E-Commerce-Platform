{{ config(materialized='view', tags=['intermediate'])}}
-- 1 row per seller
with sellers as (
    select * from {{ ref('stg_seller') }}
),
enriched_seller as (
    select 
        seller_id,
        seller_zip_code,
        r.latitude,
        r.longtitude,
        r.city,
        r.state
    from sellers seller 
    left join {{ ref('int_region') }} r
        on seller.seller_zip_code = r.geolocation_zip_code_prefix
)
select * from enriched_seller