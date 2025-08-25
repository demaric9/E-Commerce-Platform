{{ config(
    materialized = 'incremental',
    unique_key = 'review_id',
    incremental_strategy = 'delete+insert',
    tags=['mart']
) }}

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

{% if is_incremental() %}
  where review_creation_date > (select max(review_creation_date) from {{ this }})
{% endif %}