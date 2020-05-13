import logging
from typing import Dict

from env import ENV
import s3


def access_read(obj_id: str):
    url = s3.get_access_url(obj_id, ENV.AWS_GET_URL_LIFETIME_S)
    return [b"OK", url]


def access_create(obj_id: str):
    url = s3.create_presigned_post(obj_id, ENV.AWS_GET_URL_LIFETIME_S)
    return [b"OK", url]


def access_delete(obj_id: str):
    url = s3.get_delete_url(obj_id, ENV.AWS_GET_URL_LIFETIME_S)
    return [b"OK", url]


ROUTES = {
    b"/access/read": access_read,
    b"/access/create": access_create,
    b"/access/delete": access_delete,
}
