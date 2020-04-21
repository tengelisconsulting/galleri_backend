from galleri.app_types import App
from galleri.env import get_env


ENV = get_env()

def get_access_url(
        app: App,
        object_id: str,
        expiration_s: int
)-> str:
    return app.s3.generate_presigned_url(
        "get_object",
        Params = {
            "Bucket": ENV.OBJ_STORAGE_BUCKET,
            "Key": object_id,
        },
        ExpiresIn = expiration_s
    )


def get_delete_url(
        app: App,
        object_id: str,
        expiration_s: int
)-> str:
    return app.s3.generate_presigned_url(
        "delete_object",
        Params = {
            "Bucket": ENV.OBJ_STORAGE_BUCKET,
            "Key": object_id,
        },
        ExpiresIn = expiration_s
    )


def create_presigned_post(
        app: App,
        object_id: str,
        expiration_s: int,
        fields = None,
        conditions = None
):
    return app.s3.generate_presigned_post(
        ENV.OBJ_STORAGE_BUCKET,
        object_id,
        Fields = fields,
        Conditions = conditions,
        ExpiresIn = expiration_s
    )
