import base64
import logging
from urllib.parse import parse_qs
from urllib.parse import unquote as url_unquote

from mg2.framework import req_mapping
from mg2.app_types import ReqState
from mg2.app_types import ResState
import mg2.response as response
import mg2.request as request

import galleri.aws as aws
from galleri.env import get_env
import galleri.s3 as s3


ENV = get_env()

@req_mapping(path="/aws/headers-for-req", method="GET")
def get_aws_headers(
        req_state: ReqState
)-> ResState:
    q_params = parse_qs(req_state.req.headers['QUERY'])
    method = q_params["method"][0]
    url = url_unquote(q_params["url"][0])
    headers = aws.get_aws_headers(aws.AwsReq(
        method = method,
        url = url
    ))
    return response.ok({
        "aws_headers": headers,
    })


@req_mapping(path="/aws/access-url", method="GET")
def get_access_url(
        req_state: ReqState
)-> ResState:
    q_params = parse_qs(req_state.req.headers['QUERY'])
    obj_id = q_params["objId"][0]
    url = s3.get_presigned_url(
        req_state.app, obj_id, ENV.AWS_GET_URL_LIFETIME_S
    )
    encoded_url = base64.b64encode(url.encode("utf-8")).decode("utf-8")
    return response.ok({
        "url_b64": encoded_url,
    })
