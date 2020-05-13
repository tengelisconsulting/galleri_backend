import boto3

from env import ENV


session = boto3.session.Session(region_name = ENV.OBJ_STORAGE_REGION)
s3_client = session.client(
    "s3",
    config = boto3.session.Config(signature_version='s3v4'),
    aws_access_key_id = ENV.AWS_ACCESS_KEY_ID,
    aws_secret_access_key = ENV.AWS_SECRET_KEY,
)


def get_access_url(
        object_id: str,
        expiration_s: int
)-> str:
    return s3_client.generate_presigned_url(
        "get_object",
        Params = {
            "Bucket": ENV.OBJ_STORAGE_BUCKET,
            "Key": object_id,
        },
        ExpiresIn = expiration_s
    )


def get_delete_url(
        object_id: str,
        expiration_s: int
)-> str:
    return s3_client.generate_presigned_url(
        "delete_object",
        Params = {
            "Bucket": ENV.OBJ_STORAGE_BUCKET,
            "Key": object_id,
        },
        ExpiresIn = expiration_s
    )


def create_presigned_post(
        object_id: str,
        expiration_s: int,
        fields = None,
        conditions = None
):
    return s3_client.generate_presigned_post(
        ENV.OBJ_STORAGE_BUCKET,
        object_id,
        Fields = fields,
        Conditions = conditions,
        ExpiresIn = expiration_s
    )
