import uuid

import boto3
import redis
import zmq

from galleri.app_types import App
from galleri.env import get_env
import galleri.msg as msg


ENV = get_env()

def _init_redis()-> redis.Redis:
    return redis.Redis(
        host=ENV.REDIS_HOST,
        port=ENV.REDIS_PORT,
        db=0
    )


def _init_s3()-> boto3.client:
    session = boto3.session.Session(region_name = ENV.OBJ_STORAGE_REGION)
    return session.client(
        's3',
        config = boto3.session.Config(signature_version='s3v4'),
        aws_access_key_id=ENV.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=ENV.AWS_SECRET_KEY
    )


def init_app()-> App:
    app = App(
        ps_id = str(uuid.uuid4()),
        s3 = _init_s3(),
        c = zmq.Context(),
        r = _init_redis(),
        ws = None
    )
    app.ws = msg.init_work_sender(app.ps_id, app.c)
    return app
