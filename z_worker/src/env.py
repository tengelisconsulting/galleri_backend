import os
from typing import NamedTuple

class _ENV(NamedTuple):
    HTTP_ZMQ_HOST = os.environ["HTTP_ZMQ_HOST"]
    HTTP_ZMQ_HTTP_PORT = int(os.environ["HTTP_ZMQ_HTTP_PORT"])
    MG2_HANDLER_HOST = os.environ["MG2_HANDLER_HOST"]
    OBJ_STORAGE_HOST = os.environ["OBJ_STORAGE_HOST"]
    OBJ_STORAGE_BUCKET = os.environ["OBJ_STORAGE_BUCKET"]
    REDIS_HOST = os.environ["REDIS_HOST"]
    REDIS_PORT = int(os.environ["REDIS_PORT"])
    Z_WORKER_ACK_PORT = int(os.environ["Z_WORKER_ACK_PORT"])
    Z_WORKER_PORT = int(os.environ["Z_WORKER_PORT"])

ENV = _ENV()
