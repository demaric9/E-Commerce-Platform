{{ config(materialized='view') }}

with sources as (
    select * from {{ source('source_raw', 'order_reviews') }}
),
stg_order_reviews as (
    select
        cast(order_review_id as varchar) as order_review_id,
        cast(order_id as varchar) as order_id,
        cast(review_score as int) as review_score,
        cast(review_comment_title as varchar) as review_title,
        cast(review_message_title as varchar) as review_message,
        cast(review_creation_date as timestamp) as review_survey_date,
        cast(review_answer_timestamp as timestamp) as survey_answer_date
    from sources
    where order_review_id is not null
)
select * from stg_order_reviews