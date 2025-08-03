{{ config(materialized='view') }}

with sources as (
    select * from {{ source('source_raw', 'olist_sellers_dataset') }}
),
stg_sellers as (
    select 
        cast(seller_id as varchar) as seller_id,
        cast(seller_zip_code_prefix as varchar) as seller_zip_code,
        lower(trim(seller_city)) as seller_city,
        upper(trim(seller_state)) as seller_state 
    from sources
    where seller_id is not null
)
select * from stg_sellers