import base64
import json
import logging
from typing import Dict
from typing import List

import ez

import const as c
import permissions as p
from hashing import calc_hash_b64


@ez.endpoint(route=b"/access-hash")
def get_access_hash(
        exp_ts: float,
        ops: List[Dict]
):
    logging.info("OPS: %s", ops)
    claims = c.Claims(
        exp_ts=exp_ts,
        ops=[c.Op(**op) for op in ops],
    )
    hash_b64 = calc_hash_b64(claims)
    response = {
        "body": {
            "ops": [op._asdict() for op in claims.ops],
            "exp_ts": claims.exp_ts,
        },
        "hash_b64": hash_b64,
    }
    return [b"OK", {
        "body": response,
        "token": base64.b64encode(
            json.dumps(response).encode("utf-8")
        ).decode("utf-8")
    }]


@ez.endpoint(route=b"/verify/anon")
def verify_anon(
        op: Dict,
        claims_token: str
):
    claims = json.loads(base64.b64decode(claims_token.encode("utf-8")))
    claims_body = claims["body"]
    ops = [c.Op(**_op) for _op in claims_body["ops"]]
    permitted = p.check_op_for_claims(
        c.Op(**op),
        c.Claims(
            ops = ops,
            exp_ts = claims_body["exp_ts"],
        ),
        claims["hash_b64"]
    )
    if not permitted:
        return [b"ERR", b"401"]
    return [b"OK", True]


@ez.endpoint(route=b"/verify/user-id")
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
    if is_valid:
        return [b"OK", True]
    return [b"ERR", b"401"]


async def init() -> None:
    return
