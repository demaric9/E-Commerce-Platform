{{ config(materialized='table', tags=['mart']) }}

with dim_seller as (
    select * from {{ ref('int_seller') }}
)
select 
    dbt_scd_id as seller_key_unique,
    {{ dbt_utils.generate_surrogate_key(['seller_id']) }} as seller_key,
    {{ dbt_utils.generate_surrogate_key(['seller_zip_code']) }} as region_key,
    latitude, 
    longtitude,
    city,
    state,
    dbt_valid_from,
    dbt_valid_to
from dim_seller
