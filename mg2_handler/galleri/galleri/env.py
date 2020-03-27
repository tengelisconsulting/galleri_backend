import os
from typing import NamedTuple


class _ENV(NamedTuple):
    SESSION_TIMEOUT_S = int(os.environ["SESSION_TIMEOUT_S"])


def get_env()-> _ENV:
    return _ENV()
