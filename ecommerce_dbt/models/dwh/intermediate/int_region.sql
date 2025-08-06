{{ config(materialized='ephemeral', tags=['intermediate']) }}

with ranked_zip_region as (
    select
        geolocation_zip_code_prefix,
        city,
        state,
        count(*) as cnt,
        row_number() over (
            partition by geolocation_zip_code_prefix
            order by count(*) desc
        ) as rn
    from {{ ref('stg_geolocation') }}
    group by geolocation_zip_code_prefix, city, state
)

select 
    geolocation_zip_code_prefix,
    city,
    state
from ranked_zip_region
where rn = 1
