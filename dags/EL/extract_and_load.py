from airflow import DAG
from airflow.utils.log.logging_mixin import LoggingMixin
from airflow.operators.python import PythonOperator
import os, sys
sys.path.append("/opt/airflow")


from datetime import datetime
from cfg import minio_cfs

from python_script.extract_data import extract_data_pipeline
from python_script.loading_to_duckdb import load_csvs_from_minio

default_args = {
    'owner' : 'Vu',
    'start_date': datetime(2024, 1, 1),
    'retries': 1
}

with DAG(
    dag_id = 'ecommerce_extract_and_load_pipeline',
    default_args = default_args,
    schedule_interval = None,
    catchup = False,
    tags = ['duckdb', 'minio', 'ecommerce']
) as dag:
    extract_data = PythonOperator(
        task_id = 'extract_data',
        python_callable = extract_data_pipeline
    )

    loading_to_duckdb = PythonOperator (
        task_id = 'loading_to_duckdb',
        python_callable = load_csvs_from_minio
    )
extract_data >> loading_to_duckdb

