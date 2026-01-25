{% snapshot snapshots_customer %}
{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='check',     
      check_cols=['customer_unique_id','customer_zip_code_prefix','customer_city','customer_state'],
      tags=['snapshot']
    )
}}

select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
from {{ ref('stg_customer') }}

{% endsnapshot %}
