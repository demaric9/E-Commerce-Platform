{{ config(materialized='view') }}

with sources as (
    select * from {{ source('source_raw', 'olist_order_reviews_dataset') }}
),
stg_order_reviews as (
    select
        cast(review_id as varchar) as order_review_id,
        cast(order_id as varchar) as order_id,
        cast(review_score as int) as review_score,
        cast(review_comment_title as varchar) as review_title,
        cast(review_comment_message as varchar) as review_message,
        cast(review_creation_date as timestamp) as review_survey_date,
        cast(review_answer_timestamp as timestamp) as survey_answer_date
    from sources
    where order_review_id is not null
    and not (review_comment_title is null and review_comment_message is null)
)
select * from stg_order_reviews