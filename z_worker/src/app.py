import logging
from typing import NamedTuple

import redis
import requests
import zmq

from env import ENV


class App(NamedTuple):
    c: zmq.Context
    r: redis.Redis
    http_s: requests.Session
    pull: zmq.Socket


def init()-> App:
    r = redis.Redis(
        host = ENV.REDIS_HOST,
        port = ENV.REDIS_PORT,
        db = 0
    )
    c = zmq.Context()
    pull = c.socket(zmq.PULL)
    pull_con_s = f"tcp://{ENV.MG2_HANDLER_HOST}:{ENV.Z_WORKER_PORT}"
    pull.connect(pull_con_s)
    logging.info("worker pulling on %s", pull_con_s)
    return App(
        c = c,
        r = r,
        http_s = requests.Session(),
        pull = pull
    )
