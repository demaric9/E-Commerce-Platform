{{ config(materialized='view', tags=['intermediate'])}}


with products as (
    select * from {{ ref('stg_product') }}
),

enriched_product as (
    select 
        product_id,
        
        -- Product attributes
        category_name,
        t.product_category_name_english,
        product_name_length,
        product_description_length,
        photos_count,
        weight_g,
        length_cm,
        height_cm, 
        width_cm,
        row_number() over(partition by category_name order by product_id) as rn
    from products product 
    join {{ ref('stg_translation_product_category') }} t 
        on product.category_name = t.product_category_name -- category name in Portuguese
)
select * from enriched_product
where rn = 1