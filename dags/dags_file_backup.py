from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from datetime import datetime
import duckdb, json

DUCKDB_PATH = "ecommerce_db.duckdb"
DBT_PROJECT_PATH = "/opt/airflow/ecommerce_dbt"

def load_dbt_run_result():
    con = duckdb.connect(DUCKDB_PATH)

    with open(f"{DBT_PROJECT_PATH}/target/run_results.json", "r") as f:
        run_results = json.load(f)

    rows = []
    for result in run_results["results"]:
        rows.append((
            result.get("unique_id"),
            result.get("status"),
            result.get("execution_time"),
            result.get("failures")
        ))

    con.execute("""
        CREATE TABLE IF NOT EXISTS observability_run_results (
            unique_id VARCHAR,
            status VARCHAR,
            execution_time DOUBLE,
            failures INTEGER
        )
    """)
    con.executemany("INSERT INTO observability_run_results VALUES (?, ?, ?, ?)", rows)
    con.close()

def load_dbt_manifest():
    con = duckdb.connect(DUCKDB_PATH)

    with open(f"{DBT_PROJECT_PATH}/target/manifest.json", "r") as f:
        manifest = json.load(f)

    rows = []
    for node_id, node_data in manifest.get("nodes", {}).items():
        rows.append((
            node_id,
            node_data.get("name"),
            node_data.get("resource_type"),
            json.dumps(node_data.get("depends_on", {}).get("nodes", [])),
            json.dumps(node_data.get("tags", [])),
            node_data.get("description", ""),
            datetime.utcnow()
        ))

    con.execute("""
        CREATE TABLE IF NOT EXISTS observability_manifest (
            node_id VARCHAR,
            model_name VARCHAR,
            resource_type VARCHAR,
            depends_on_json VARCHAR,
            tags_json VARCHAR,
            description VARCHAR,
            load_time TIMESTAMP)
    """)
    con.executemany("""
        INSERT INTO observability_manifest 
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, rows)

    con.close()

default_args = {
    'owner': 'Vu',
    'start_date': datetime(2024, 1, 1),
    'retries': 0
}

with DAG(
    dag_id="load_dbt_logs",
    default_args=default_args,
    schedule_interval=None,
    catchup=False
) as dag:
    test_task = PythonOperator(
        task_id='load_manifest',
        python_callable=load_dbt_manifest
    )

    test_task_2 = PythonOperator(
        task_id='load_run_results',
        python_callable=load_dbt_run_result
    )

    trigger_load_postgres = TriggerDagRunOperator(
         task_id='trigger_load_postgres',
         trigger_dag_id='duckdb_to_postgres_full',
         wait_for_completion=False,
         reset_dag_run=True
    )
    test_task >> test_task_2 >> trigger_load_postgres
