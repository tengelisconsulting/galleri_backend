import logging
import time
from typing import cast
from typing import Dict
from typing import List
from typing import Optional

import const as c
import permissions as p
from hashing import calc_hash_b64


def get_read_access_hash(
        obj_id: str,
        exp_ts: float
):
    claims = c.Claims(
        obj_id = obj_id,
        exp_ts = exp_ts,
        ops = [c.READ],
    )
    hash_b64 = calc_hash_b64(claims)
    return [b"OK", {"hash_b64": hash_b64}]


def verify_anon(
        obj_id: str,
        op: str,
        claims: Dict,
        claims_hash_b64: str
):
    logging.info("claims: %s", claims)
    if op == c.READ:
        is_valid = p.check_read_for_claims(
            obj_id, c.Claims(**claims), claims_hash_b64
        )
    elif op == c.WRITE:
        is_valid = p.check_write_for_claims(
            obj_id, c.Claims(**claims), claims_hash_b64
        )
    else:
        logging.error("not an op: %s", op)
        return [b"ERR", b"400"]
    if not is_valid:
        return [b"ERR", b"401"]
    logging.info("valid!")
    return [b"OK", True]


def verify_user_id(
        obj_id: str,
        op: str,
        user_id: str
):
    is_valid = False
    if op == c.READ:
        is_valid = p.check_read_for_user_id(obj_id, user_id)
    elif op == c.WRITE:
        is_valid = p.check_write_for_user_id(obj_id, user_id)
    else:
        logging.error("not an op: %s", op)
        return [b"ERR", b"400"]
    logging.info("user %s %s access to %s  - %s",
                 user_id, op, obj_id, is_valid)
    if is_valid:
        return [b"OK", True]
    return [b"ERR", b"401"]




ROUTES = {
    b"/read-access-hash": get_read_access_hash,
    b"/verify/anon": verify_anon,
    b"/verify/user-id": verify_user_id,
}
