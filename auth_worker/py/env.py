import os
from typing import NamedTuple


class _ENV(NamedTuple):
    # generic
    LISTEN_HOST: str = os.environ["LISTEN_HOST"]
    PORT: int = int(os.environ["PORT"])
    SERVICE_NAME: str = os.environ["SERVICE_NAME"]
    # impl
ENV = _ENV()
