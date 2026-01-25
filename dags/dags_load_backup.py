from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
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
    dag_id="load_backup",
    default_args=default_args,
    schedule_interval=None,
    catchup=False
) as dag:

    t1 = PythonOperator(
        task_id="load_backup_minio",
        python_callable=backup_duckdb
    )

    t2 = PythonOperator(
        task_id="clean_backup_minio",
        python_callable=cleanup_duckdb
    )

    trigger_load_logs = TriggerDagRunOperator(
         task_id='trigger_load_logs',
         trigger_dag_id='load_dbt_logs',
         wait_for_completion=False,
         reset_dag_run=True
    )

    t1 >> t2 >> trigger_load_logs