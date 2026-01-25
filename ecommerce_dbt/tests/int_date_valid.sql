SELECT *
FROM {{ ref('int_orders_items') }}
WHERE total_item_value < 0