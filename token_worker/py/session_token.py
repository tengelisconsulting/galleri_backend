import logging
import time
from typing import Dict

import jwt

from env import ENV


PRIV_KEY_FILE = "/app/priv_key"

_token_sig: str
with open(PRIV_KEY_FILE, "r") as f:
    _token_sig = f.read()
_ALGO = "HS256"


def create_token(
        user_id: str,
        is_refresh: bool = False,
        session_timeout_s: int = ENV.SESSION_TIMEOUT_S
)-> str:
    exp_time = time.time() + session_timeout_s
    token_byes = jwt.encode(
        {
            "exp": exp_time,
            # app-defined
            "user_id": user_id,
            "is_refresh": is_refresh,
        },
        _token_sig,
        algorithm = _ALGO
    )
    return token_byes.decode("utf-8")


def get_claims(
        token: str,
        is_refresh: bool = False
)-> Dict:
    claims = jwt.decode(
        token,
        _token_sig,
        algorithms=[_ALGO]
    )
    if claims["is_refresh"] != is_refresh:
        raise Exception("bad token type")
    return claims
