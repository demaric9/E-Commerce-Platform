{{ config(materialized='view', tags=['staging']) }}

with sources as (
    select * from {{ source('source_raw', 'olist_order_reviews_dataset') }}
),
stg_order_reviews as (
    select
        cast(review_id as varchar) as review_id,
        cast(order_id as varchar) as order_id,
        cast(review_score as int) as review_score,
        cast(review_comment_title as varchar) as review_title,
        cast(review_comment_message as varchar) as review_message,
        cast(review_creation_date as timestamp) as review_creation_date,
        cast(review_answer_timestamp as timestamp) as review_answer_date
    from sources
    where review_id is not null
)
select * from stg_order_reviews