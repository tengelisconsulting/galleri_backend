import logging

from mg2.framework import req_mapping
from mg2.app_types import ReqState
from mg2.app_types import ResState
import mg2.response as response
import mg2.request as request


@req_mapping(path="/upload/obj-storage", method="POST")
def new_session_token(
        req_state: ReqState
)-> ResState:
    logging.info(
        "going to upload file to aws..."
    )
    return response.ok({
        "everything": "ok",
    })
