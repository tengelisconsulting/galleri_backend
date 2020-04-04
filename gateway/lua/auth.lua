local cjson = require "cjson"

local app_cookie = require "lua/app_cookie"
local app_http = require "lua/app_http"
local downstream = require "lua/downstream"
local log = require "lua/log"

local REFRESH_TOKEN_NAME = "galleri_refresh_token"
local TOKEN_CAPTURE = "Bearer: (.*)"


-- private
local function get_token(user_id, is_refresh)
   local function get_path()
      if is_refresh then
         return "/token/new/refresh"
      end
      return "/token/new/session"
   end
   local token_req_body = cjson.encode({
         user_id = user_id
   })
   local token_res = app_http.req_http_zmq({
         path = get_path(),
         method = "POST",
         body = token_req_body,
   })
   if token_res.err then
      return nil, "failed to create token"
   end
   local token = cjson.decode(token_res.body).token
   return token, nil
end


local function respond_new_session(user_id)
   local function fail(status, err_msg)
      ngx.status = status
      local res = cjson.encode({
            err = err_msg
      })
      ngx.say(res)
   end
   local session_token, err = get_token(user_id, false)
   if err then
      ngx.log(ngx.ERR,
              "failed to create session token for user id " .. user_id)
      fail(502, "failed to create session")
      return
   end
   local refresh_token, err_ref = get_token(user_id, true)
   if err then
      ngx.log(ngx.ERR,
              "failed to create refresh token for user id " .. user_id)
      fail(502, "failed to create session")
      return
   end

   local ok, err = app_cookie.set({
         key = REFRESH_TOKEN_NAME,
         value = refresh_token,
         path = "/",
         http_only = true,
   })
   if not ok then
      ngx.log(ngx.ERR, err)
      fail(500, "failed creating session")
      return
   end
   local res = cjson.encode({
         session_token = session_token
   })
   ngx.say(res)
end

-- public
local function init_user()
   local data = downstream.get_body_table()
   local req_body = cjson.encode({
         p_username = data.username,
         p_password = data.password,
         p_role_names = cjson.empty_array,
   })
   ngx.log(ngx.NOTICE, req_body)
   app_http.proxy_sys_pgst({
         path = "/rpc/ac_init_user",
         method = "POST",
         headers = {},
         body = req_body,
   })
end

local function authenticate_username_password()
   local data = downstream.get_body_table()
   local req_body = cjson.encode({
         p_username = data.username,
         p_password = data.password
   })
   local login_res = app_http.req_sys_pgst({
         path = "/rpc/check_username_password",
         method = "POST",
         body = req_body,
   })
   if login_res.status ~= 200 then
      ngx.status = 401
      ngx.say(login_res.err)
      return
   end
   local user_id = string.gsub(
      cjson.decode(login_res.body), "%s", ""
   )
   if string.len(user_id) == 0 then
      ngx.status = 401
      ngx.say(cjson.encode("invalid credentials"))
      return
   end
   return respond_new_session(user_id)
end


local function renew_session()
   local refresh_token, err = app_cookie.get(REFRESH_TOKEN_NAME)
   if not refresh_token then
      ngx.status = 401
      local res = cjson.encode({
            err = "no refresh token"
      })
      ngx.say(res)
   end
   local session_res = app_http.req_http_zmq({
         path = "/token/parse",
         method = "POST",
         body = cjson.encode({
               token = refresh_token,
               is_refresh = true,
         }),
   })
   if session_res.status ~= 200 then
      ngx.log(ngx.ERR, session_res.err)
      ngx.status = 401
      ngx.say(cjson.encode({
                    err = "invalid refresh token"
      }))
      return
   end
   local claims = cjson.decode(session_res.body).claims
   return respond_new_session(claims.user_id)
end

local function authenticate_fail(err_msg)
   local status = 401
   local msg = "request authorizaation failed - " .. err_msg
   ngx.status = status
   log.err(msg)
   ngx.say(cjson.encode({
                 err = msg
   }))
   ngx.exit(status)
end

local function authorize_fail(err_msg)
   local status = 403
   local msg = "request authorization failed - " .. err_msg
   ngx.status = status
   log.err(msg)
   ngx.say(cjson.encode({
                 err = msg
   }))
   ngx.exit(status)
end

local function authenticate_req()
   local auth_header = ngx.var.http_authorization
   if not auth_header then
      authenticate_fail("no auth header")
      return
   end
   local _, _, token = string.find(auth_header, TOKEN_CAPTURE)
   if not token then
      authenticate_fail("bad auth header")
      return
   end
   -- get user id from token
   local session_res = app_http.req_http_zmq({
         path = "/token/parse",
         method = "POST",
         body = cjson.encode({
               token = token,
               is_refresh = false,
         }),
   })
   if session_res.err then
      authenticate_fail("token verification failed")
      return
   end
   local res_body = cjson.decode(session_res.body)
   local user_id = res_body.claims.user_id
   ngx.req.set_header("user-id", user_id)
   return user_id
end

local function authorize_owner(user_id, obj_id)
   local headers = {}
   headers["user-id"] = user_id
   local auth_res = app_http.req_sys_pgst({
         path = "/rpc/check_session_owns",
         method = "POST",
         body = cjson.encode({
               p_obj_id = obj_id
         }),
         headers = headers
   })
   if auth_res.err then
      authorize_fail("failed to determine session ownership")
      return
   end
   local is_success = cjson.decode(auth_res.body)
   if is_success == true then
      return true
   end
   authorize_fail("session requested access to an object it don't own")
end

-- module
local M = {}
M.authenticate_username_password = authenticate_username_password
M.init_user = init_user
M.renew_session = renew_session
M.authenticate_req = authenticate_req
M.authorize_owner = authorize_owner
return M
