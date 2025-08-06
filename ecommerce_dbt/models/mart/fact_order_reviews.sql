{{ config(materialized='table') }}

with int_order_reviews as (
    select * from {{ ref('int_reviews') }}
)

select
    review_id,
    order_id,
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    review_score,
    review_creation_date
from int_order_reviews