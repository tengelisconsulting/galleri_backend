from datetime import datetime
import hashlib
import hmac
import re
from typing import Dict
from typing import NamedTuple
from urllib.parse import urlparse

from galleri.env import get_env


ACCESS_KEY = get_env().AWS_ACCESS_KEY_ID
SECRET_KEY = get_env().AWS_SECRET_KEY

UNSIGNED_PAYLOAD = "UNSIGNED-PAYLOAD"
SIGV4_TIMESTAMP = '%Y%m%dT%H%M%SZ'

SERVICE_REGION_REGX = re.compile("(.*)\.(.*)\.amazonaws\.com")

class _Req(NamedTuple):
    now: datetime
    method: str
    url: str
    service: str
    region: str


class AwsReq(NamedTuple):
    method: str
    url: str


def get_aws_headers(req: AwsReq)-> Dict:
    hostname = urlparse(req.url).hostname
    service, region = re.search(SERVICE_REGION_REGX, hostname) \
                        .groups()
    req = _Req(
        now = datetime.utcnow(),
        method = req.method,
        url = req.url,
        service = service,
        region = region,
    )
    headers = _get_no_auth_headers(req)
    headers['Authorization'] = _get_auth_header(req)
    return headers


def _get_auth_header(req: _Req)-> str:
    sig_vsn = "AWS4-HMAC-SHA256"
    cred_date = req.now.strftime("%Y%m%d")
    credential = f"{ACCESS_KEY}/{cred_date}/{req.region}/{req.service}/aws4_request"
    signed_headers = _get_signed_headers(req)
    string_to_sign = _get_string_to_sign(req)
    signature = _hmac_sha256(
        _get_signing_key(req), string_to_sign, is_hex = True
    )
    return f"{sig_vsn} Credential={credential}, SignedHeaders={signed_headers}, Signature={signature}"


def _get_string_to_sign(req: _Req)-> str:
    algo = "AWS4-HMAC-SHA256"
    can_req = _get_canonical_request(req)
    hashed_req = _hex_hash(can_req.encode("utf-8"))
    time_s = req.now.strftime("%Y%m%d") + "T" \
        + req.now.strftime("%H%M%S") + "Z"
    cred_scope = req.now.strftime("%Y%m%d") + "/" \
        + req.region + "/" + f"{req.service}/aws4_request"
    return f"{algo}\n{time_s}\n{cred_scope}\n{hashed_req}"


def _get_signing_key(req: _Req)-> str:
    date_key = _hmac_sha256(
        ("AWS4" + SECRET_KEY).encode("utf-8"),
        req.now.strftime("%Y%m%d")
    )
    region_key = _hmac_sha256(
        date_key, req.region
    )
    service_key = _hmac_sha256(
        region_key, req.service
    )
    signing_key = _hmac_sha256(
        service_key, "aws4_request"
    )
    return signing_key


def _hmac_sha256(key: bytes, msg: str, is_hex = False)-> str:
    signed = hmac.new(
        key,
        msg = msg.encode("utf-8"),
        digestmod = hashlib.sha256
    )
    if is_hex:
        return signed.hexdigest().lower()
    else:
        return signed.digest()


def _get_canonical_request(req: _Req)-> str:
    can_uri = urlparse(req.url).path
    # can_qs = req.query_s
    can_qs = ""
    can_headers = _get_canonical_headers(req)
    signed_headers = _get_signed_headers(req)
    hashed_payload = UNSIGNED_PAYLOAD
    return f"{req.method}\n{can_uri}\n{can_qs}\n{can_headers}\n{signed_headers}\n{hashed_payload}"


def _hex_hash(b: bytes) -> str:
    return hashlib.sha256(b) \
                  .hexdigest() \
                  .lower()


def _get_canonical_headers(req: _Req)-> str:
    headers = _get_no_auth_headers(req)
    def format_line(key: str):
        val = headers[key]
        line = f"{key}:{val}".strip()
        return re.sub(
            "\s+", " ", line
        )
    lines = [
        format_line(header) for header in
        sorted(headers.keys())
    ]
    return "\n".join(lines) + "\n" # THERE IS A NEWLINE AT THE END


def _get_signed_headers(req: _Req)-> str:
    headers = _get_no_auth_headers(req)
    return ";".join(
        sorted(headers.keys())
    )


def _get_no_auth_headers(req: _Req)-> Dict:
    # as best I can tell, header values should not be lowercased,
    # but the keys must
    hostname = urlparse(req.url).hostname
    return {
        'host': hostname,
        'x-amz-content-sha256': UNSIGNED_PAYLOAD,
        'x-amz-date': req.now.strftime(SIGV4_TIMESTAMP)
    }
