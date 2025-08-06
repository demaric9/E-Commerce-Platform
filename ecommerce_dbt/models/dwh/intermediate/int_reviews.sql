{{ config(materialized='ephemeral', tags=['intermediate']) }}

with raw_reviews as (
    select * from {{ ref('stg_order_review') }}
),

ranked_view as (
    select *,
        row_number() over (partition by review_id
                            order by review_creation_date desc) as row_num 
        from raw_reviews                    
),

reviews as (
    select * 
    from ranked_view
    where row_num = 1
),

enriched_reviews as (
    select
        r.review_id,
        r.order_id,
        customer_id,
        r.review_score,
        cast(review_creation_date as date) as review_creation_date

    from reviews r 
    left join {{ ref('stg_order') }} o using(order_id) 
)

select * from enriched_reviews
