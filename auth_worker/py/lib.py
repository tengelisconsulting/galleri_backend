import base64
import hashlib
import hmac
import json


PRIV_KEY_FILE = "/app/priv_key"

_key: bytes
with open(PRIV_KEY_FILE, "rb") as f:
    _key = f.read()


def calc_hash_b64(
        obj_id: str,
        exp_ts: int
)-> str:
    payload = {
        "obj_id": obj_id,
        "exp_ts": exp_ts,
    }
    payload_bytes = json.dumps(payload) \
                        .encode("utf-8")
    payload_hmac = hmac.new(_key, digestmod = hashlib.sha256)
    payload_hmac.update(payload_bytes)
    token_bytes = payload_hmac.digest()
    return base64.b64encode(token_bytes) \
                 .decode("utf-8")
