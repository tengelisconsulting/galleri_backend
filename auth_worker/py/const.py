from typing import NamedTuple
from typing import List


class Op(NamedTuple):
    method: str
    url: str

class Claims(NamedTuple):
    exp_ts: float
    ops: List[Op]


READ = "r"
WRITE = "w"
