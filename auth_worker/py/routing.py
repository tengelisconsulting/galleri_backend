import logging
import time

import lib


def validate_access_token(
        obj_id: str,
        exp_ts: int,
        token: str
):
    if exp_ts < time.time():
        return [b"ERR", "401"]
    hash_b64 = lib.calc_hash_b64(obj_id, exp_ts)
    if hash_b64 == token:
        return [b"OK", True]
    return [b"ERR", "401"]


def generate_access_token(
        obj_id: str,
        exp_ts: int              # None is never
):
    hash_b64 = lib.calc_hash_b64(obj_id, exp_ts)
    return [b"OK", {"token": hash_b64}]


ROUTES = {
    b"/generate-access-token": generate_access_token,
    b"/validate-access-token": validate_access_token,
}
