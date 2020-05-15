import logging
import time
from typing import cast
from typing import Dict
from typing import List
from typing import Optional

import const as c
import permissions as p
from hashing import calc_hash_b64


def generate_access_token(
        obj_id: str,
        exp_ts: float,
        ops: List[str]
):
    claims = c.Claims(
        obj_id = obj_id,
        exp_ts = exp_ts,
        ops = ops,
    )
    hash_b64 = calc_hash_b64(claims)
    return [b"OK", {"token": hash_b64}]


def verify(
        obj_id: str,
        op: str,
        user_id: Optional[str] = None,
        claims: Optional[Dict] = None,
        claims_hash_b64: Optional[str] = None
):
    def is_valid()-> bool:
        if op == c.READ:
            if user_id:
                return p.check_read_for_user_id(obj_id, user_id)
            claims = cast(Dict, claims)
            return p.check_read_for_claims(
                obj_id, c.Claims(**claims), cast(str, claims_hash_b64)
            )
        if op == c.WRITE:
            if user_id:
                return p.check_write_for_user_id(obj_id, user_id)
            claims = cast(Dict, claims)
            return p.check_write_for_claims(
                obj_id, c.Claims(**claims), cast(str, claims_hash_b64)
            )
        logging.error("not an op: %s", op)
        return False
    if not is_valid():
        return [b"ERR", "401"]
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
        return [b"ERR", "400"]
    logging.info("user %s %s access to %s  - %s",
                 user_id, op, obj_id, is_valid)
    if is_valid:
        return [b"OK", True]
    return [b"ERR", "401"]




ROUTES = {
    b"/generate-access-token": generate_access_token,
    b"/verify/user-id": verify_user_id,
}
