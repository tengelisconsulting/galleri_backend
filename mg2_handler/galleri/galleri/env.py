import os
from typing import NamedTuple


class _ENV(NamedTuple):
    AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
    AWS_SECRET_KEY = os.environ["AWS_SECRET_KEY"]
    SESSION_TIMEOUT_S = int(os.environ["SESSION_TIMEOUT_S"])


def get_env()-> _ENV:
    return _ENV()
