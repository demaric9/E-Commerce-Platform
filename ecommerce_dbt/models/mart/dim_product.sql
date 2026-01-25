{{ config(materialized='table', tags=['mart']) }} 

with dim_product as ( select * from {{ ref('int_product') }} ) 

select 
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key, 
    product_id, category_name, 
    product_category_name_english, 
    product_name_length, 
    product_description_length, 
    photos_count,
    weight_g,
    length_cm,
    height_cm,
    width_cm 
from dim_product
where dbt_valid_to is null