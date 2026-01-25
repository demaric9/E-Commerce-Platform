{{ config(materialized='table', tags=['staging']) }}

with sources as (
    select * from {{ source('source_raw', 'product_category_name_translation') }}
),
stg_translation_category_name as (
    select
        cast(product_category_name as varchar) as product_category_name,
        cast(product_category_name_english as varchar) as product_category_name_english
    from sources
)
select * from stg_translation_category_name