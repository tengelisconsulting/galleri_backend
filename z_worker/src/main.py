#!/usr/bin/env python3

import logging
import os
import time
from typing import Callable
from typing import NamedTuple

import requests
import zmq

from mg2.run import setup_logging

from app import App
from app import init as init_app
from env import ENV
import upload


def parse_msg(
        app: App,
        msg
)-> (Callable, str):
    try:
        sender_id, req_id, service_id, task_id, more, body = msg
        if service_id != b"AD_HOC":
            logging.error("unknown service id - %s", service_id)
            return None, "unknown service id"
        if task_id != b"UPLOAD_REDIS":
            logging.error("unknown task id - %s", task_id)
            return None, "unknown task id"
        executor = lambda: upload.upload_redis(app, body)
        return executor, None
    except Exception as e:
        logging.exception("failed to parse msg - %s", e)
        return None, "failed to parse msg"


def listen_for_work(
        app: App
)-> None:
    msg = app.pull.recv_multipart()
    logging.debug("recvd msg %s", msg)
    executor, err = parse_msg(app, msg)
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


def start_handler_loop(app: App)-> None:
    time.sleep(2)
    while True:
        try:
            listen_for_work(app)
        except Exception as e:
            logging.exception("worker died - %s", e)


def main()-> None:
    setup_logging()
    app = init_app()
    start_handler_loop(app)


if __name__ == "__main__":
    main()
