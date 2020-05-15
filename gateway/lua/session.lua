local cjson = require "cjson"

local app_http = require "lua/app_http"
local app_cookie = require "lua/app_cookie"
local downstream = require "lua/downstream"
local ez = require "lua/ez"
local log = require "lua/log"

local REFRESH_TOKEN_NAME = "galleri_refresh_token"
local TOKEN_CAPTURE = "Bearer: (.*)"


-- private
local function authenticate_fail(err_msg)
   local status = 401
   local msg = "request authorizaation failed - " .. err_msg
   respond.die(401, msg)
end

local function get_token(user_id, is_refresh)
   local function get_path()
      if is_refresh then
         return "/token/new/refresh"
      end
      return "/token/new/session"
   end
   local token_res, err = ez.r("SESSION", get_path(), {user_id = user_id})
   if err then
      return nil, err
   end
   return token_res.token, nil
end


local function respond_new_session(user_id)
   local function fail(status, err_msg)
      ngx.status = status
      local res = cjson.encode({err = err_msg})
      ngx.say(res)
   end
   local session_token, err = get_token(user_id, false)
   if err then
      log.err("failed to create session token for user id %s - %s", user_id, err)
      fail(502, "failed to create session")
      return
   end
   local refresh_token, err_ref = get_token(user_id, true)
   if err then
      log.err("failed to create refresh token for user id %s", user_id)
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
      log.err(err)
      fail(500, "failed creating session")
      return
   end
   local res = cjson.encode({
         session_token = session_token,
         user_id = user_id,
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
   if login_res.err then
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

local function end_session()
   local ok, err = app_cookie.set({
         key = REFRESH_TOKEN_NAME,
         value = "",
         path = "/",
         http_only = true,
   })
   ngx.say(cjson.encode("ok"))
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
   local session_res, err = ez.r("SESSION", "/token/parse", {
                                    token = refresh_token,
                                    is_refresh = true,
   })
   if err then
      ngx.log(ngx.ERR, err)
      ngx.status = 401
      ngx.say(cjson.encode({err = "invalid refresh token"}))
      return
   end
   local claims = session_res.claims
   return respond_new_session(claims.user_id)
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
   local session_res, err = ez.r("SESSION", "/token/parse", {
                                    token = token,
                                    is_refresh = false
   })
   if err then
      authenticate_fail("token verification failed")
      return
   end
   local user_id = session_res.claims.user_id
   ngx.var.user_id = user_id
   ngx.req.set_header("user-id", user_id)
   return user_id
end


local M = {}
M.authenticate_req = authenticate_req
M.authenticate_username_password = authenticate_username_password
M.end_session = end_session
M.init_user = init_user
M.renew_session = renew_session
return M
