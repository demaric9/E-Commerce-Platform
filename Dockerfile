FROM apache/airflow:2.9.0-python3.10

USER airflow
RUN pip install \
    minio \
    duckdb \
    dbt-core==1.10.5 \
    dbt-duckdb==1.9.4

USER airflow
