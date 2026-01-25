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
    review_score,
    review_creation_date,
    cast(strftime(review_creation_date, '%Y%m%d') as integer) as date_key,
    loaded_at
from int_order_reviews

{% if is_incremental() %}
  where loaded_at > (select max(loaded_at) from {{ this }})
{% endif %}
