from datetime import datetime
from datetime import timedelta
from typing import Dict

import jwt

from galleri.env import get_env


env = get_env()

def _get_token_sig()-> str:
    return "priv_key"


def _get_algo()-> str:
    return "HS256"


def create_token(
        user_id: str,
        is_refresh: bool,
        session_timeout_s: int = env.SESSION_TIMEOUT_S
)-> str:
    exp_time = (
        datetime.now() + timedelta(seconds=session_timeout_s)
    ).timestamp()
    return jwt.encode(
        {
            "exp": exp_time,
            # app-defined
            "user_id": user_id,
            "is_refresh": is_refresh,
        },
        _get_token_sig(),
        algorithm=_get_algo()
    ).decode("utf-8")


def parse_token(
        token: str
)-> Dict:
    claims = jwt.decode(
        token,
        _get_token_sig(),
        algorithms=[_get_algo()]
    )
    return claims
