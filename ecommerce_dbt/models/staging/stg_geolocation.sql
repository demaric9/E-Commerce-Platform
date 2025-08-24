{{ config(materialized='table', tags=['staging']) }}

with sources as (
    select * from {{ source('source_raw', 'olist_geolocation_dataset') }}
),
stg_geolocation as (
    select
        cast(geolocation_zip_code_prefix as varchar) as geolocation_zip_code_prefix,
        cast(geolocation_lat as double) as latitude,
        cast(geolocation_lng as double) as longtitude,
        lower(trim(geolocation_city)) as city,
        upper(trim(geolocation_state)) as state
    from sources
    where geolocation_zip_code_prefix is not null
)
select * from stg_geolocation