#!/usr/bin/env python3

import logging
import os
import time
from typing import Callable
from typing import NamedTuple

import requests
import zmq

from mg2.run import setup_logging


class _ENV(NamedTuple):
    MG2_HANDLER_HOST = os.environ["MG2_HANDLER_HOST"]
    REDIS_HOST = os.environ["REDIS_HOST"]
    REDIS_PORT = int(os.environ["REDIS_PORT"])
    Z_WORKER_ACK_PORT = int(os.environ["Z_WORKER_ACK_PORT"])
    Z_WORKER_PORT = int(os.environ["Z_WORKER_PORT"])

ENV = _ENV()


def upload_redis(obj_id: bytes)-> (None, str):
    logging.info("uploading %s from redis", obj_id)
    return None, None


def parse_msg(msg)-> (Callable, str):
    try:
        sender_id, req_id, service_id, task_id, more, body = msg
        if service_id != b"AD_HOC":
            logging.error("unknown service id - %s", service_id)
            return None, "unknown service id"
        if task_id != b"UPLOAD_REDIS":
            logging.error("unknown task id - %s", task_id)
            return None, "unknown task id"
        executor = lambda: upload_redis(body)
        return executor, None
    except Exception as e:
        logging.exception("failed to parse msg - %s", e)
        return None, "failed to parse msg"


def listen_for_work(pull)-> None:
    msg = pull.recv_multipart()
    logging.debug("recvd msg %s", msg)
    executor, err = parse_msg(msg)
    if err:
        logging.error("giving up on message - %s", err)
        return
    try:
        _result, err = executor()
        if err:
            logging.error("handler failed - %s", err)
            return
    except Exception as e:
        logging.exception("failed handling msg - %s", e)


def main()-> None:
    setup_logging()
    c = zmq.Context()
    pull = c.socket(zmq.PULL)
    pull_con_s = f"tcp://{ENV.MG2_HANDLER_HOST}:{ENV.Z_WORKER_PORT}"
    pull.connect(pull_con_s)
    time.sleep(2)
    logging.info("listening for work at %s", pull_con_s)
    while True:
        try:
            listen_for_work(pull)
        except Exception as e:
            logging.exception("worker died - %s", e)


if __name__ == "__main__":
    main()
