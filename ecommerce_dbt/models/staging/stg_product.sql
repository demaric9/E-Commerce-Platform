{{ config(materialized='view', tags=['staging']) }}

with sources as (
    select * from {{ source('source_raw', 'olist_products_dataset') }}
),
stg_products as (
    select 
        cast(product_id as varchar) as product_id,
        trim(product_category_name) as category_name,
        cast(product_name_lenght as int) as product_name_length,
        cast(product_description_lenght as int) as product_description_length,
        cast(product_photos_qty as int) as photos_count,
        cast(product_weight_g as int) as weight_g,
        cast(product_length_cm as int) as length_cm,
        cast(product_height_cm as int) as height_cm,
        cast(product_width_cm as int) as width_cm
    from sources 
    WHERE product_id IS NOT NULL
        AND product_category_name IS NOT NULL
        AND product_name_lenght IS NOT NULL
        AND product_description_lenght IS NOT NULL
        AND product_photos_qty IS NOT NULL
        AND product_weight_g IS NOT NULL
        AND product_length_cm IS NOT NULL
        AND product_height_cm IS NOT NULL
        AND product_width_cm IS NOT NULL
)

select * from stg_products