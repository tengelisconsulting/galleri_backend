import os
from typing import NamedTuple


class _ENV(NamedTuple):
    # generic
    LISTEN_HOST: str = os.environ["LISTEN_HOST"]
    PORT: int = int(os.environ["PORT"])
    SERVICE_NAME: str = os.environ["SERVICE_NAME"]
    # impl
    ACCEESS_TOKEN_SECRET: bytes = os.environ["ACCEESS_TOKEN_SECRET"] \
                                    .encode("utf-8")
    SYS_PGST_HOST: str = os.environ["SYS_PGST_HOST"]
    SYS_PGST_PORT: int = int(os.environ["SYS_PGST_PORT"])
ENV = _ENV()
