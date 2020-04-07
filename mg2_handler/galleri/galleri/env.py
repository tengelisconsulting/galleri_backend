import os
from typing import NamedTuple


class _ENV(NamedTuple):
    AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
    AWS_SECRET_KEY = os.environ["AWS_SECRET_KEY"]
    SESSION_TIMEOUT_S = int(os.environ["SESSION_TIMEOUT_S"])
    REDIS_HOST = os.environ["REDIS_HOST"]
    REDIS_PORT = int(os.environ["REDIS_PORT"])
    MG2_HANDLER_HOST = os.environ["MG2_HANDLER_HOST"]
    Z_WORKER_ACK_PORT = int(os.environ["Z_WORKER_ACK_PORT"])
    Z_WORKER_PORT = int(os.environ["Z_WORKER_PORT"])


def get_env()-> _ENV:
    return _ENV()
