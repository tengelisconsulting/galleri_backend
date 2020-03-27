from mg2.framework import req_mapping
from mg2.app_types import ReqState
from mg2.app_types import ResState
import mg2.response as response


@req_mapping(path="/test", method="GET")
def test(
        state: ReqState
)-> ResState:
    body = {
        "test": "success"
    }
    return response.ok(body)
