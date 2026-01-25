FROM apache/airflow:2.9.0-python3.10

USER airflow
RUN pip install \
    minio \
    duckdb \
    dbt-core==1.10.6 \
    dbt-duckdb==1.9.4 \
    openlineage-dbt
RUN pip install apache-airflow-providers-postgres psycopg2-binary pandas sqlalchemy 
RUN pip install google-cloud-pubsub>=2.23.0 "protobuf>=5.0,<6.0"
USER airflow
