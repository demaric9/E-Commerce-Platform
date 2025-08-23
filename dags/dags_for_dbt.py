from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import sys
from datetime import datetime, timedelta
sys.path.append("/opt/airflow")
from cfg import minio_cfs

minio_client = minio_cfs.minio_client
FILE_PATH = "/opt/airflow/ecommerce_db.duckdb"
BUCKET_NAME = "backup-duckdb"
RETENTION_DAYS = 7

def backup_duckdb():
    if not minio_client.bucket_exists(BUCKET_NAME):
        minio_client.make_bucket(BUCKET_NAME)
    
    object_name = f"ecommerce_db_{datetime.now().strftime('%Y%m%d_%H%M%S')}.duckdb"

    minio_client.fput_object(BUCKET_NAME, object_name,FILE_PATH)
    print("Successfully backup")

def cleanup_duckdb():
    objects = minio_client.list_objects(BUCKET_NAME)
    cutoff_date = datetime.now() - timedelta(days=RETENTION_DAYS)

    for obj in objects:
        try:
            ts_str = obj.object_name.replace("ecommerce_db_", "").replace(".duckdb", "")
            ts = datetime.strptime(ts_str, "%Y%m%d_%H%M%S")
            if ts < cutoff_date:
                minio_client.remove_object(BUCKET_NAME, obj.object_name)
                print(f"Deleted old backup: {obj.object_name}")
        except Exception as e:
                print(f"Skip {obj.object_name}, reason: {e}")


default_args = {
    'owner': 'Vu',
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
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
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt-ol build --select tag:staging',
        env={'PATH': '/home/airflow/.local/bin:/usr/local/bin:/usr/bin:/bin'}
    )

    dbt_build_intermediate = BashOperator(
        task_id='dbt_run_intermediate',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt-ol build --select tag:intermediate',
        env={'PATH': '/home/airflow/.local/bin:/usr/local/bin:/usr/bin:/bin'}
    )

    dbt_build_mart = BashOperator(
        task_id='dbt_run_mart',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt build --select tag:mart',
        env={'PATH': '/home/airflow/.local/bin:/usr/local/bin:/usr/bin:/bin'}
    )

    dbt_run_docs = BashOperator(
        task_id='dbt_run_docs',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt docs generate'
    )

    dbt_run_backup = PythonOperator(
        task_id='dbt_run_backup',
        python_callable=backup_duckdb
    )

    dbt_run_cleanup_backdup = PythonOperator(
         task_id='dbt_run_cleanup_backup',
         python_callable=cleanup_duckdb
    )

    dbt_deps >> dbt_build_staging \
              >> dbt_build_intermediate \
              >> dbt_build_mart \
              >> dbt_run_docs \
              >> dbt_run_backup >> dbt_run_cleanup_backdup
