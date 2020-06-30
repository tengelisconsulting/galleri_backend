import logging
from typing import Dict

import ez
import session_token


@ez.endpoint(route=b"/token/new/refresh")
async def new_refresh_token(
        user_id: str
):
    token = session_token.create_token(user_id, is_refresh=True)
    logging.debug("new refresh token for user id: %s", user_id)
    return [b"OK", {"token": token}]


@ez.endpoint(route=b"/token/new/session")
async def new_session_token(
        user_id: str
):
    token = session_token.create_token(user_id, is_refresh=False)
    logging.debug("new session token for user id: %s", user_id)
    return [b"OK", {"token": token}]


@ez.endpoint(route=b"/token/parse")
async def parse_token(
        token: str,
        is_refresh: bool
):
    try:
        claims = session_token.get_claims(token, is_refresh=is_refresh)
    except Exception:
        return [b"ERR", b"401"]
    return [b"OK", {"claims": claims}]


async def init() -> None:
    return
