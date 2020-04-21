from types import SimpleNamespace
from typing import Tuple

import boto3
import redis
import zmq


Packet = Tuple[
    bytes,                      # sender_id
    bytes,                      # req_id
    bytes,                      # service_id
    bytes,                      # task_id
    bytes,                      # more
    bytes                       # body
]

class WorkSender(SimpleNamespace):
    req_n: int
    push: zmq.Socket


class App(SimpleNamespace):
    ps_id: str
    s3: boto3.client
    c: zmq.Context
    r: redis.Redis
    ws: WorkSender
