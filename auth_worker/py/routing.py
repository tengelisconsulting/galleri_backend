import logging
from typing import Dict

import session_token


def new_refresh_token(
        user_id: str
):
    token = session_token.create_token(user_id, is_refresh = True)
    logging.debug("new refresh token for user id: %s", user_id)
    return [b"OK", {"token": token}]


def new_session_token(
        user_id: str
):
    token = session_token.create_token(user_id, is_refresh = False)
    logging.debug("new session token for user id: %s", user_id)
    return [b"OK", {"token": token}]


def parse_token(
        token: str,
        is_refresh: bool
):
    try:
        claims = session_token.get_claims(token, is_refresh = is_refresh)
    except Exception as e:
        return [b"ERR", b"401"]
    return [b"OK", {"claims": claims}]



ROUTES = {
    b"/token/new/refresh": new_refresh_token,
    b"/token/new/session": new_session_token,
    b"/token/parse": parse_token,
}
