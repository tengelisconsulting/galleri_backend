import logging
import urllib.parse
from typing import Dict

from app import App
from env import ENV


HTTP_ZMQ_CON_S = f"http://{ENV.HTTP_ZMQ_HOST}:{ENV.HTTP_ZMQ_HTTP_PORT}"

def _get_target_url(obj_id)-> str:
    return f"{ENV.OBJ_STORAGE_HOST}/{ENV>OBJ_STORAGE_BUCKET}"


def _get_aws_headers(app: App, obj_id)-> Dict:
    target_url = _get_target_url(obj_id)
    target_url_encoded = urllib.parse.quote(target_url)
    headers = app.http_s.get(
        url=f"{HTTP_ZMQ_CON_S}/aws/headers-for-req?method=PUT&url={target_url_encoded}",
    )
    logging.info("headers: %s", headers)


def upload_redis(
        app: App,
        obj_id: bytes
)-> (None, str):
    content = app.r.get(obj_id)
    logging.info("uploading %s from redis - %d", obj_id, len(content))
    return None, None
