{{ config(materialized='table', tags=['mart']) }}

with date_get as (
{{ dbt_date.get_date_dimension("2016-01-01", "2019-01-01") }}
)

select 
    *,
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key
from date_get
