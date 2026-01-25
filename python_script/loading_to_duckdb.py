import duckdb
import os

def load_csvs_from_minio():
    print("Hello")
    # Connect to DuckDB
    con = duckdb.connect(os.path.abspath("ecommerce_db.duckdb"))
    
    # Load httpfs
    con.execute("INSTALL httpfs")
    con.execute("LOAD httpfs")

    # Config MinIO through S3 API
    con.execute("SET s3_region='us-east-1'")
    con.execute("SET s3_url_style='path'")
    con.execute("SET s3_endpoint='host.docker.internal:9000'") 
    con.execute("SET s3_access_key_id='minioadmin'")
    con.execute("SET s3_secret_access_key='minioadmin'")
    con.execute("SET s3_use_ssl=false")

    # Loop through bucket in MinIO
    base_prefix = "s3://ecommerce-raw/raw/"  # path to bucket
    result = con.execute(f"""
        SELECT * FROM glob('{base_prefix}*.csv')
    """).fetchall()

    if not result:
        print(" Not found.")
        return

    # Loop thourgh .csv files and load to DuckDB
    for (file_path,) in result:
        table_name = file_path.split("/")[-1].replace(".csv", "")
        print(f"Loading: {file_path} to Table: {table_name}")
        con.execute(f"""
            CREATE OR REPLACE TABLE {table_name} AS
            SELECT *, current_timestamp as loaded_at FROM read_csv_auto('{file_path}')
        """)

    con.close()
    print("Complete load DuckDB.")

if __name__ == "__main__":
    load_csvs_from_minio()

