import os
from typing import NamedTuple


class _ENV(NamedTuple):
    # generic
    LISTEN_HOST: str = os.environ["LISTEN_HOST"]
    PORT: int = int(os.environ["PORT"])
    SERVICE_NAME: str = os.environ["SERVICE_NAME"]
    # suspect all these
    AWS_ACCESS_KEY_ID: str = os.environ["AWS_ACCESS_KEY_ID"]
    AWS_GET_URL_LIFETIME_S: int = int(os.environ["AWS_GET_URL_LIFETIME_S"])
    AWS_SECRET_KEY: str = os.environ["AWS_SECRET_KEY"]
    OBJ_STORAGE_BUCKET: str = os.environ["OBJ_STORAGE_BUCKET"]
    OBJ_STORAGE_REGION: str = os.environ["OBJ_STORAGE_REGION"]
ENV = _ENV()
