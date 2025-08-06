{{ config(materialized='table') }}

with dim_customer as (
    select * from {{ ref('int_customer') }}
)

select 
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    city,
    state
from dim_customer
    