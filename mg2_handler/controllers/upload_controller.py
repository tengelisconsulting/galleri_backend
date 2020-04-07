import logging

from mg2.framework import req_mapping
from mg2.app_types import ReqState
from mg2.app_types import ResState
import mg2.response as response
import mg2.request as request

import galleri.msg as msg


@req_mapping(path="/upload/obj-storage", method="POST")
def upload_obj_storage(
        req: ReqState
)-> ResState:
    obj_id = request.read_body(req)["obj_id"]
    contents = req.app.r.get(obj_id)
    logging.info(
        "going to upload %s to aws... %s", obj_id, len(contents)
    )
    msg.send_upload_redis(req.app, obj_id.encode("utf-8"))
    return response.ok("ok")
