{{ config(materialized='view') }}

with sources as (
    select * from {{ source('sources_raw', 'products') }}
),
stg_products as (
    select 
        cast(product_id as varchar) as product_id,
        trim(product_category_name) as category_name,
        cast(product_name_lenght as int) as name_length,
        cast(product_description_lenght as int) as description_length,
        cast(product_photos_qty as int) as photos_count,
        cast(product_weight_g as int) as weight_g,
        cast(product_length_cm as int) as length_cm,
        cast(product_height_cm as int) as height_cm,
        cast(product_width_cm as int) as width_cm
    from sources 
    where product_id is not null
)

select * from stg_products