import logging
import re
import time
from typing import Dict
from typing import List
from typing import NamedTuple

import requests

import const as c
from env import ENV
import hashing


PERMITTED_READ_NO_OBJ = False
PERMITTED_WRITE_NO_OBJ = True

permission_load_url = "http://{}:{}/obj_permissions" \
    .format(ENV.SYS_PGST_HOST, ENV.SYS_PGST_PORT)


class ObjPermission(NamedTuple):
    owner_id: str
    public_read: bool
    public_write: bool


# init
_permissions: Dict[str, ObjPermission]
def to_obj_permission(row)-> ObjPermission:
    owner = row["permissions"]["owner"]
    public = row["permissions"]["public"]
    return ObjPermission(
        owner_id = row["owner_id"],
        public_read = "r" in public and public["r"] == "t",
        public_write = "w" in public and public["w"] == "t",
    )
def load_permissions()-> None:
    global _permissions
    _permissions = {}
    with requests.Session() as s:
        res = s.get(permission_load_url)
        data = res.json()
        for row in data:
            _permissions[row["obj_id"]] = to_obj_permission(row)
    return
load_permissions()


# private
def _includes_op(permitted_ops: List[c.Op], op: c.Op)-> bool:
    for permitted_op in permitted_ops:
        if permitted_op.method != op.method:
            continue
        if re.match(permitted_op.url, op.url):
            return True
    return False


def _verify_claims(
        op: c.Op,
        claims: c.Claims
)-> bool:
    if not _includes_op(claims.ops, op):
        logging.error("claims don't permit op")
        return False
    if claims.exp_ts < time.time():
        logging.error("claims expired")
        return False
    return True


def load_permission(obj_id: str)-> None:
    with requests.Session() as s:
        res = s.get(permission_load_url + f"?obj_id=eq.{obj_id}")
        if not res.ok:
            return
        data = res.json()
        if not data:
            return
        _permissions[obj_id] = to_obj_permission(data[0])
    return


# public
def check_read_for_user_id(
        obj_id: str,
        user_id: str
)-> bool:
    if obj_id not in _permissions:
        load_permission(obj_id)
    if obj_id not in _permissions:
        return PERMITTED_READ_NO_OBJ
    p = _permissions[obj_id]
    if p.public_read:
        return True
    return p.owner_id == user_id


def check_write_for_user_id(
        obj_id: str,
        user_id: str
)-> bool:
    if obj_id not in _permissions:
        load_permission(obj_id)
    if obj_id not in _permissions:
        return PERMITTED_WRITE_NO_OBJ
    p = _permissions[obj_id]
    if p.public_write:
        return True
    return p.owner_id == user_id


def check_op_for_claims(
        op: c.Op,
        claims: c.Claims,
        claims_hash_b64: str
)-> bool:
    if not claims:
        return False
    if not _verify_claims(op, claims):
        return False
    correct_hash = hashing.calc_hash_b64(claims)
    return claims_hash_b64 == correct_hash
