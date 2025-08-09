{{ config(materialized='table') }}

select *, 
       {{ dbt_utils.generate_surrogate_key(['geolocation_zip_code_prefix']) }} as region_key,
from {{ ref('int_region') }}