from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import sys
from datetime import datetime
sys.path.append("/opt/airflow")
from cfg import minio_cfs

minio_client = minio_cfs.minio_client
FILE_PATH = "/opt/airflow/ecommerce_db.duckdb"
BUCKET_NAME = "backup-duckdb"

def backup_duckdb():
    if not minio_client.bucket_exists(BUCKET_NAME):
        minio_client.make_bucket(BUCKET_NAME)
    
    object_name = f"ecommerce_db_{datetime.now().strftime('%Y%m%d_%H%M%S')}.duckdb"

    minio_client.fput_object(BUCKET_NAME, object_name,FILE_PATH)
    print("Successfully backup")

default_args = {
    'owner': 'Vu',
    'start_date': datetime(2024, 1, 1),
    'retries': 1
}

with DAG(
    dag_id='dbt_pipeline',
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=['dbt', 'ecommerce']
) as dag:

    dbt_deps = BashOperator(
        task_id='dbt_deps',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt deps'
    )
    
    dbt_build_staging = BashOperator(
        task_id='dbt_run_staging',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt build --select tag:staging'
    )

    dbt_build_intermediate = BashOperator(
        task_id='dbt_run_intermediate',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt build --select tag:intermediate'
    )

    dbt_build_mart = BashOperator(
        task_id='dbt_run_mart',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt build --select tag:mart'
    )

    dbt_run_docs = BashOperator(
        task_id='dbt_run_docs',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt docs generate'
    )

    dbt_run_backup = PythonOperator(
        task_id='dbt_run_backup',
        python_callable=backup_duckdb
    )

    dbt_deps >> dbt_build_staging \
              >> dbt_build_intermediate \
              >> dbt_build_mart \
              >> dbt_run_docs \
              >> dbt_run_backup
