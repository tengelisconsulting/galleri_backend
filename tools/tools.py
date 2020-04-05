import atexit
import json
import threading
from typing import Dict
from typing import NamedTuple

import requests


_USER = "test_user"
_PSWD = "a1s2d3f4g5"
PROTOCOL = "http"
HOST = "127.0.0.1"
SESS_RENEW_S = 25 * 60


class Sess(NamedTuple):
    http_sess: requests.Session
    timers: Dict


def _renew_session(s: Sess)-> None:
    r = s.http_sess.post(f"{PROTOCOL}://{HOST}/auth/renew-session")
    return r.ok


def _setup_session_refresh(
        s: Sess
)-> None:
    def reset_timer(cb):
        s.timers["session"] = threading.Timer(SESS_RENEW_S, cb)
        s.timers["session"].start()
        return
    def renew_session():
        if not _renew_session(s):
            print("FAILED TO RENEW SESSION")
            if "session" in s.timers:
                print("CANCELING RENEW TIMER")
                s.timers["session"].cancel()
        else:
            reset_timer(renew_session)
        return
    reset_timer(renew_session)
    return


def destroy(s: Sess)-> None:
    if "session" in s.timers:
        s.timers["session"].cancel()
    s.http_sess.close()
    return


def init_test_sess()-> Sess:
    hs = requests.Session()
    login_url = f"{PROTOCOL}://{HOST}/auth/authenticate/username-password"
    data = json.dumps({
        "username": _USER,
        "password": _PSWD,
    })
    res = hs.post(login_url, data)
    if not res.ok:
        raise Exception("failed to init session - %s".format(res.text))
    token = res.json()["session_token"]
    hs.headers = {
        "Authorization": f"Bearer: {token}"
    }
    sess = Sess(
        http_sess = hs,
        timers = {}
    )
    _setup_session_refresh(sess)
    def cleanup():
        destroy(sess)
        return
    atexit.register(cleanup)
    return sess
