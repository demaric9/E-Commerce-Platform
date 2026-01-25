{{ config(materialized='table', tags=['mart']) }}

with dim_customer as (
    select * from {{ ref('int_customer') }}
)
select 
        dbt_scd_id as customer_key_unique,
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
        customer_unique_id,
        {{ dbt_utils.generate_surrogate_key(['customer_zip_code_prefix']) }} as region_key,
        latitude, 
        longtitude,
        city,
        state,
        dbt_valid_from,
        dbt_valid_to
from dim_customer
