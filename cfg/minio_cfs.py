from minio import Minio

minio_client = Minio(
    endpoint='host.docker.internal:9000',
    access_key='minioadmin',
    secret_key='minioadmin',
    secure = False
)