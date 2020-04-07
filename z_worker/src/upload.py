from enum import Enum
import logging
import urllib.parse
from typing import Callable
from typing import Dict

from app import App
from env import ENV


class ExitState(Enum):
    DO_NOTHING = 0


HTTP_ZMQ_CON_S = f"http://{ENV.HTTP_ZMQ_HOST}:{ENV.HTTP_ZMQ_HTTP_PORT}"
OBJ_STORAGE_ENDPOINT = f"{ENV.OBJ_STORAGE_HOST}/{ENV.OBJ_STORAGE_BUCKET}"

UPLOAD_METHOD = "PUT"


def _get_target_url(obj_id: bytes)-> str:
    obj_id_s = obj_id.decode("utf-8")
    return f"https://{OBJ_STORAGE_ENDPOINT}/{obj_id_s}"


def _get_aws_headers(app: App, obj_id: bytes)-> Dict:
    target_url = _get_target_url(obj_id)
    target_url_encoded = urllib.parse.quote(target_url)
    headers_res = app.http_s.get(
        url=f"{HTTP_ZMQ_CON_S}/aws/headers-for-req?method={UPLOAD_METHOD}&url={target_url_encoded}",
    )
    return headers_res.json()["aws_headers"]


def _delete_redis_key(
        app: App,
        obj_id: bytes
)-> None:
    logging.debug("deleting %s from redis", obj_id)
    app.r.delete(obj_id)


def cleanup(
        exit_state: ExitState = None
)-> Callable:
    def do_noting(_app, _body):
        return None
    if exit_state == ExitState.DO_NOTHING:
        return do_nothing
    return _delete_redis_key


def upload_redis(
        app: App,
        obj_id: bytes
)-> ExitState:
    content = app.r.get(obj_id)
    if not content:
        return ExitState.DO_NOTHING
    headers = _get_aws_headers(app, obj_id)
    target_url = _get_target_url(obj_id)
    logging.debug("uploading %s to - %s", obj_id, target_url)
    r = app.http_s.request(
        method = UPLOAD_METHOD,
        url = target_url,
        headers = headers,
        data = content
    )
    if not r.ok:
        err_s = f"{r.code} - {r.text}"
        logging.error(
            "failed to upload %s - %s", obj_id, err_s
        )
        return
    logging.info("upload %s success", obj_id)
