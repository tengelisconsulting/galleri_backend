from typing import NamedTuple
from typing import List


class Claims(NamedTuple):
    obj_id: str
    exp_ts: float
    ops: List[str]


READ = "r"
WRITE = "w"
