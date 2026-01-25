{% snapshot snapshots_product %}
{{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='check',
      check_cols=['category_name','product_name_length','product_description_length',
      'photos_count', 'weight_g', 'length_cm','height_cm','width_cm'],
      tags=['snapshot']
    )
}}

    select 
        product_id,
        category_name,
        product_name_length,
        product_description_length,
        photos_count,
        weight_g,
        length_cm,
        height_cm,
        width_cm
    from {{ ref('stg_product') }}

{% endsnapshot %}