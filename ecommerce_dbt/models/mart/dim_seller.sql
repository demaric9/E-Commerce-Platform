{{ config(materialized='table') }}

with dim_seller as (
    select * from {{ ref('int_seller') }}
)

select 
    {{ dbt_utils.generate_surrogate_key(['seller_id']) }} as seller_key,
    seller_id,
    {{ dbt_utils.generate_surrogate_key(['seller_zip_code']) }} as region_key,
    latitude, 
    longtitude,
    city,
    state
from dim_seller