import ez
from env import ENV
import s3


@ez.endpoint(route=b"/access/read")
async def access_read(obj_id: str):
    url = s3.get_access_url(obj_id, ENV.AWS_GET_URL_LIFETIME_S)
    return [b"OK", url]


@ez.endpoint(route=b"/access/create")
async def access_create(obj_id: str):
    url = s3.create_presigned_post(obj_id, ENV.AWS_GET_URL_LIFETIME_S)
    return [b"OK", url]


@ez.endpoint(route=b"/access/delete")
async def access_delete(obj_id: str):
    url = s3.get_delete_url(obj_id, ENV.AWS_GET_URL_LIFETIME_S)
    return [b"OK", url]


async def init() -> None:
    return
