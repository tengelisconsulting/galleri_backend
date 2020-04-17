import base64
import io
import json
import logging

from PIL import Image
import requests

from app import App
from env import ENV


def _thumbnail_size():
    return (404, 250)

def save_thumbnail(
        app: App,
        obj_id: bytes
)-> None:
    image_bytes = app.r.get(obj_id)
    image_b_stream = io.BytesIO(image_bytes)
    orig = Image.open(image_b_stream)
    smaller = orig.resize(_thumbnail_size(), Image.ANTIALIAS)
    smaller_bytes: bytes
    with io.BytesIO() as smaller_stream:
        smaller.save(smaller_stream,
                     format="JPEG",
                     optimize=True,
                     quality=50)
        smaller_bytes = smaller_stream.getvalue()
    encoded = base64.b64encode(smaller_bytes)
    url = f"http://{ENV.SYS_PGST_HOST}:{ENV.SYS_PGST_PORT}/rpc/image_update"
    with requests.Session() as s:
        res = s.post(url, data = json.dumps({
            "p_obj_id": obj_id.decode("utf-8"),
            "p_thumb_b64": encoded.decode("utf-8"),
        }))
        if not res.ok:
            logging.error("failed to set thumbnail")
        else:
            logging.info("%s thumbnail saved", obj_id)
    return
