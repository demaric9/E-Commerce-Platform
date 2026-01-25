{{ config(materialized='table', tags=['mart']) }}

with dim_customer as (
    select * from {{ ref('int_customer') }}
)

select 
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    customer_id,
    customer_unique_id,
    {{ dbt_utils.generate_surrogate_key(['customer_zip_code_prefix']) }} as region_key,
    latitude, 
    longtitude,
    city,
    state
from dim_customer
    