from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
import sys
from datetime import datetime, timedelta
sys.path.append("/opt/airflow")
from cfg import minio_cfs


default_args = {
    'owner': 'Vu',
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id='transform_dbt',
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=['dbt', 'ecommerce']
) as dag:
    
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
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt-ol build --select tag:mart',
        env={'PATH': '/home/airflow/.local/bin:/usr/local/bin:/usr/bin:/bin'}
    )

    trigger_load_backup = TriggerDagRunOperator(
         task_id='trigger_load_backup',
         trigger_dag_id='load_backup',
         wait_for_completion=False,
         reset_dag_run=True
    )

    dbt_build_staging \
    >> dbt_build_intermediate \
    >> dbt_build_mart \
    >> trigger_load_backup
