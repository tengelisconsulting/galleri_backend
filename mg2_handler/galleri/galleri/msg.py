import logging
import time
from typing import Tuple

import zmq

from galleri.app_types import App
from galleri.app_types import Packet
from galleri.app_types import WorkSender
from galleri.env import get_env


ENV = get_env()


def to_packet(
        sender_id: str = None,
        req_id: int = None,
        service_id: str = None,
        task_id: str = None,
        more: bool = False,
        body: bytes = None
)-> Packet:
    return (
        sender_id.encode("utf-8"),
        b"%d" % req_id,
        service_id.encode("utf-8"),
        task_id.encode("utf-8"),
        b"\01" if more else b"\00",
        body
    )


def send(
        app: App,
        packet: Packet,
)-> None:
    app.ws.push.send_multipart(packet)
    return


def init_work_sender(
        wid: str,
        c: zmq.Context
)-> WorkSender:
    push = c.socket(zmq.PUSH)
    push_con_s = f"tcp://{ENV.MG2_HANDLER_HOST}:{ENV.Z_WORKER_PORT}"
    push.bind(push_con_s)
    logging.info("pushing work to %s", push_con_s)
    return WorkSender(
        req_n = 0,
        push = push
    )


def send_upload_redis(
        app: App,
        body: bytes
)-> None:
    app.ws.req_n = app.ws.req_n + 1
    packet = to_packet(
        sender_id = app.ps_id,
        req_id = app.ws.req_n,
        service_id = "AD_HOC",
        task_id = "UPLOAD_REDIS",
        body = body
    )
    send(app, packet)
    return
