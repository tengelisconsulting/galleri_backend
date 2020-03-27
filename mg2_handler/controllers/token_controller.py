import logging

from galleri.token import create_token

from mg2.framework import req_mapping
from mg2.app_types import ReqState
from mg2.app_types import ResState
import mg2.response as response
import mg2.request as request


@req_mapping(path="/token/new/session", method="POST")
def new_session_token(
        req_state: ReqState
)-> ResState:
    user_id = request.read_body(req_state)["user_id"]
    token = create_token(user_id, False)
    logging.debug(
        "new session token for user id: %s", user_id
    )
    return response.ok({
        "token": token,
    })


@req_mapping(path="/token/new/refresh", method="POST")
def new_refresh_token(
        req_state: ReqState
)-> ResState:
    user_id = request.read_body(req_state)["user_id"]
    token = create_token(user_id, True)
    logging.debug(
        "new refrersh token for user id: %s", user_id
    )
    return response.ok({
        "token": token,
    })
