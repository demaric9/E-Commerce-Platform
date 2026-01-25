from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import duckdb
import pandas as pd
from sqlalchemy import create_engine, text
from datetime import timedelta

DUCKDB_PATH = "ecommerce_db.duckdb"
PG_CONN_STR = "postgresql+psycopg2://user_ecommerce_db:user_ecommerce_db@host.docker.internal:5432/ecommerce_db"
SCHEMA = "main_mart"

def extract_metadata(**context):
    con = duckdb.connect(DUCKDB_PATH)
    tables = []
    results = con.execute(f"""
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema = '{SCHEMA}';
    """).fetchall()
    tables = [
        (s, t) for s, t in results
    ]
    context['ti'].xcom_push(key='tables', value=tables)
    print(f"{len(tables)} tables in {SCHEMA}")

def load_tables_to_postgres(**context):
    tables = context['ti'].xcom_pull(key='tables')
    con_duck = duckdb.connect(DUCKDB_PATH)
    engine_pg = create_engine(PG_CONN_STR)

    with engine_pg.connect() as conn:
        for schema, table in tables:
            conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS "{schema}"'))
            
            df = con_duck.execute(f'SELECT * FROM "{schema}"."{table}"').fetchdf()
            df.to_sql(table, engine_pg, schema=schema, if_exists='replace', index=False)
            print(f"Loaded table {schema}.{table}")

default_args = {
    'owner': 'Vu',
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=1)
}

with DAG(
    dag_id="duckdb_to_postgres_full",
    default_args=default_args,
    schedule_interval=None,
    catchup=False
) as dag:

    t1 = PythonOperator(
        task_id="extract_metadata",
        python_callable=extract_metadata
    )

    t2 = PythonOperator(
        task_id="load_tables_to_postgres",
        python_callable=load_tables_to_postgres
    )
    t1 >> t2
