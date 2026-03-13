{% macro insert_new_row_timestamp(source_name, table_name, edwLoadDate) %}

    {# Resolve the source relation #}
    {% set src = source(source_name, table_name) %}

    {# Fetch columns and their data types from the actual table #}
    {% set columns = adapter.get_columns_in_relation(src) %}

    {% if columns | length == 0 %}
        {{ exceptions.raise_compiler_error("No columns found for source " ~ source_name ~ "." ~ table_name ~ ". Does the table exist in the warehouse?") }}
    {% endif %}

    {# Build the INSERT statement with random values per column type #}
    {% set insert_sql %}
        INSERT INTO {{ src }} (
            {%- for col in columns %}
                {{ col.name }}{% if not loop.last %},{% endif %}
            {%- endfor %}
        )
        SELECT
        {%- for col in columns %}
            {% set dtype = col.dtype | upper %}

            {%- if col.name | lower == 'edwloaddate' -%}
                {%- if dtype in ('DATE',) -%}
                    PARSE_DATE('%d-%m-%Y', '{{ edwLoadDate }}')
                {%- elif dtype in ('TIMESTAMP', 'DATETIME') -%}
                    PARSE_TIMESTAMP('%d-%m-%Y', '{{ edwLoadDate }}')
                {%- else -%}
                    CAST('{{ edwLoadDate }}' AS STRING)
                {%- endif %}

            {%- elif dtype in ('INT64', 'INTEGER', 'INT', 'SMALLINT', 'BIGINT', 'TINYINT', 'BYTEINT') -%}
                CAST(FLOOR(RAND() * 1000000) AS INT64)

            {%- elif dtype in ('FLOAT64', 'FLOAT', 'NUMERIC', 'BIGNUMERIC', 'DECIMAL', 'DOUBLE') -%}
                ROUND(RAND() * 10000, 2)

            {%- elif dtype in ('DATE',) -%}
                DATE_ADD(DATE '2020-01-01', INTERVAL CAST(FLOOR(RAND() * 2000) AS INT64) DAY)

            {%- elif dtype in ('TIMESTAMP', 'DATETIME') -%}
                TIMESTAMP_ADD(TIMESTAMP '2020-01-01 00:00:00 UTC', INTERVAL CAST(FLOOR(RAND() * 2000 * 24) AS INT64) HOUR)

            {%- elif dtype in ('BOOL', 'BOOLEAN') -%}
                (RAND() > 0.5)

            {%- else -%}
                {# Default: treat as STRING #}
                CONCAT('val_', CAST(CAST(FLOOR(RAND() * 100000) AS INT64) AS STRING))

            {%- endif %}
                AS {{ col.name }}{% if not loop.last %},{% endif %}
        {%- endfor %}
    {% endset %}

    {% do log("Executing INSERT into " ~ src ~ " with edwLoadDate=" ~ edwLoadDate ~ "...", info=True) %}
    {% do run_query(insert_sql) %}
    {% do log("Successfully inserted 1 row into " ~ src ~ " with edwLoadDate=" ~ edwLoadDate, info=True) %}

{% endmacro %}
