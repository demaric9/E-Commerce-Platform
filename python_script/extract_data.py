import os
from cfg import minio_cfs

minio_client = minio_cfs.minio_client
print(minio_client.list_buckets())

def checking_bucket(minio_client, bucket_name):
    if not minio_client.bucket_exists(bucket_name):
        minio_client.make_bucket(bucket_name)

def loading_to_minio(local_path, bucket_name, minio_client):
    for filename in os.listdir(local_path):
        if filename.endswith('.csv'):
            file_path = os.path.join(local_path, filename)
            object_name = f"raw/{filename}"

            minio_client.fput_object(
                bucket_name,
                object_name,
                file_path,
                content_type='application/csv'
            )
            print(f"Uploaded {object_name}")

def extract_data_pipeline():
    local_path = '/opt/airflow/data'
    bucket_name = 'ecommerce-raw'
    checking_bucket(minio_client, bucket_name)

    loading_to_minio(local_path, bucket_name, minio_client)

if __name__ == '__main__':
    extract_data_pipeline()

