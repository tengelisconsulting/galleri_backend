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


TASK_MAP = {
    b"UPLOAD_REDIS" : (
        upload.upload_redis, upload.cleanup
    )
}


def parse_msg(
        app: App,
        msg
)-> (Callable, str):
    sender_id, req_id, service_id, task_id, more, body = msg
    if service_id != b"AD_HOC":
        raise Exception("unknown service id - %s" % service_id)
    if task_id not in TASK_MAP:
        raise Exception("unknown task id - %s" % task_id)
    logging.info("recevied %s - %s", service_id, task_id)
    cleanup, handler = TASK_MAP[task_id]
    return cleanup, handler, body


def listen_for_work(
        app: App
)-> None:
    msg = app.pull.recv_multipart()
    logging.debug("recvd msg %s", msg)
    handler, cleanup, body = None, None, None
    try:
        handler, cleanup, body = parse_msg(app, msg)
        logging.debug("exec %s with body %s", handler, body)
    except Exception as e:
        logging.exception("failed parsing msg - %s", e)
        return
    try:
        exit_state = handler(app, body)
        if exit_state is not None:
            logging.error("handler failed with known state - %s.", exit_state)
            logging.debug("attempt to rollback from state - %s", exit_state)
            cleanup(exit_state)(app, body)
    except Exception as e:
        logging.exception("handler failed with unknown state - %s", e)
        cleanup()(app, body)


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
