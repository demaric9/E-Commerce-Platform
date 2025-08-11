from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    'owner' : 'Vu',
    'start_date': datetime(2024, 1, 1),
    'retries': 1
}

with DAG(
    dag_id = 'run_dbt_pipeline',
    default_args = default_args,
    schedule_interval = None,
    catchup = False,
    tags = ['dbt', 'ecommerce']
) as dag:
    dbt_deps = BashOperator(
        task_id = 'dbt_deps',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt deps'
    )
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt run'
    )

    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /opt/airflow/ecommerce_dbt && dbt test'
    )
dbt_deps >> dbt_run >> dbt_test