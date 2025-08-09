{{ config(materialized='table') }}

with int_order_reviews as (
    select * from {{ ref('int_reviews') }}
)

select
    review_id,
    order_id,
    d.order_key,
    review_score,
    review_creation_date
from int_order_reviews
join {{ ref('dim_order') }} d using (order_id)