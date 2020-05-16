import base64
import hashlib
import hmac
import json
import logging
from typing import List

import const as c
from env import ENV


def calc_hash_b64(claims: c.Claims)-> str:
    payload_bytes = json.dumps(claims._asdict()) \
                        .encode("utf-8")
    payload_hmac = hmac.new(ENV.ACCEESS_TOKEN_SECRET,
                            digestmod = hashlib.sha256)
    payload_hmac.update(payload_bytes)
    token_bytes = payload_hmac.digest()
    return base64.b64encode(token_bytes) \
                 .decode("utf-8")
