#!/usr/bin/env python3

import asyncio
import uuid

import redis
import zmq

from mg2.run import start_handler_loop

from galleri.app_types import App
from galleri.env import get_env
import galleri.msg as msg


ENV = get_env()


def init_redis()-> redis.Redis:
    return redis.Redis(
        host=ENV.REDIS_HOST,
        port=ENV.REDIS_PORT,
        db=0
    )


def main():
    app = App(
        ps_id = str(uuid.uuid4()),
        c = zmq.Context(),
        r = init_redis(),
        ws = None
    )
    app.ws = msg.init_work_sender(app.ps_id, app.c)
    asyncio.run(
        start_handler_loop(app)
    )


if __name__ == "__main__":
    main()
