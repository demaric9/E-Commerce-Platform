{% snapshot snapshots_seller %}
{{
    config(
      target_schema='snapshots',
      unique_key='seller_id',
      strategy='check',     
      check_cols=['seller_zip_code','seller_city','seller_state'],
      tags=['snapshot']
    )
}}

select
    seller_id,
    seller_zip_code,
    seller_city,
    seller_state
from {{ ref('stg_seller') }}

{% endsnapshot %}