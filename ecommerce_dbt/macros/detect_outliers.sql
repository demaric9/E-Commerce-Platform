{% macro detect_outliers(table, column, method='iqr', percent=0.05) %}
    {% if method == 'iqr' %}
        WITH stats AS (
            SELECT
                percentile_cont(0.25) WITHIN GROUP (ORDER BY {{ column }}) AS q1,
                percentile_cont(0.75) WITHIN GROUP (ORDER BY {{ column }}) AS q3
            FROM {{ table }}
        ),
        bounds AS (
            SELECT
                q1,
                q3,
                q3 - q1 AS iqr,
                q1 - 1.5 * (q3 - q1) AS lower_bound,
                q3 + 1.5 * (q3 - q1) AS upper_bound
            FROM stats
        )
        SELECT
            t.*,
            CASE 
                WHEN t.{{ column }} < b.lower_bound OR t.{{ column }} > b.upper_bound THEN 1
                ELSE 0
            END AS is_outlier
        FROM {{ table }} t, bounds b

    {% elif method == 'percent' %}
        WITH stats AS (
            SELECT 
                AVG({{ column }}) AS mean_val
            FROM {{ table }}
        ),
        bounds AS (
            SELECT
                mean_val,
                mean_val * (1 - {{ percent }}) AS lower_bound,
                mean_val * (1 + {{ percent }}) AS upper_bound
            FROM stats
        )
        SELECT
            t.*,
            CASE 
                WHEN t.{{ column }} < b.lower_bound OR t.{{ column }} > b.upper_bound THEN 1
                ELSE 0
            END AS is_outlier
        FROM {{ table }} t, bounds b

    {% else %}
        {{ exceptions.raise_compiler_error("Unsupported method: " ~ method) }}
    {% endif %}
{% endmacro %}
