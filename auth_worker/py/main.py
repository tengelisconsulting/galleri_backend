#!/usr/bin/env python3

import asyncio
import json
from json import JSONDecodeError
import logging
import os
from typing import Any
from typing import Callable
from typing import Dict
from typing import NamedTuple

import ez_arch_worker.api as ez_worker
from ez_arch_worker.api import Frames

from env import ENV
from routing import ROUTES



def setup_logging()-> None:
    logging.basicConfig(
        level=os.environ.get("LOG_LEVEL", "INFO"),
        format=f"%(asctime)s.%(msecs)03d "
        "%(levelname)s %(module)s - %(funcName)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    return


async def handler(
        _state,
        frames: Frames
)-> Frames:
    # structure of req is [ cmd: str, args: json ].  Args must be dict.
    # structure of res is [ ok: b"OK" or b"ERR", body: json ]
    # if res is b"ERR", the body should be an http status code (as bytes)
    cmd = frames[0]
    if cmd not in ROUTES:
        return (None, [b"ERR", b"404"])
    body: Dict
    try:
        if frames[1] == b"":
            body = {}
        else:
            body = json.loads(frames[1])
    except JSONDecodeError as e:
        logging.exception("body decode failed: %s", e)
        return (None, [b"ERR", b"400"])
    try:
        handler: Any = ROUTES[cmd]
        res = handler(**body)
    except Exception as e:
        logging.exception("worker handler failed: %s", e)
        return (None, [b"ERR", b"500"])
    if res[0] == b"OK":
        res[1] = json.dumps(res[1]).encode("utf-8")
    return (None, res)


async def run_loop():
    await ez_worker.run_worker(
        service_name = b"AUTH",
        handler = handler,
        initial_state = None,
        listen_host = ENV.LISTEN_HOST,
        port = ENV.PORT,
    )


def main():
    setup_logging()
    asyncio.run(run_loop())
    return


if __name__ == "__main__":
    main()
