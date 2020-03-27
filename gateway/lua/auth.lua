local cjson = require "cjson"
local ck = require "resty.cookie"

local app_http = require "lua/app_http"
local downstream = require "lua/downstream"


-- private
local function respond_new_session()
   local token_req_body = cjson.encode({
         user_id = "a-user-id"
   })
   local session_token_res = app_http.req_http_zmq({
         path = "/token/new/session",
         method = "POST",
         body = token_req_body,
   })
   if session_token_res.err then
      ngx.status = 502
      ngx.say(cjson.encode({
                    err = "failed to create session"
      }))
      return
   end
   local refresh_token_res = app_http.req_http_zmq({
         path = "/token/new/refresh",
         method = "POST",
         body = token_req_body,
   })
   if refresh_token_res.err then
      ngx.status = 502
      ngx.say(cjson.encode({
                    err = "failed to create session"
      }))
      return
   end
   local session_token = cjson.decode(session_token_res.body).token
   local refresh_token = cjson.decode(refresh_token_res.body).token
   local cookie, err = ck:new()
   if not cookie then
      ngx.log(ngx.ERR, err)
      return
   end
   local ok, err = cookie:set({
         key = "galleri_refresh_token",
         value = refresh_token,
         path = "/",
         http_only = true,
   })
   if not ok then
      ngx.log(ngx.ERR, err)
      return
   end
   ngx.say(
      cjson.encode({
            session_token = session_token
      })
   )
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
   app_http.proxy_pgst({
         path = "/rpc/ac_init_user",
         method = "POST",
         headers = {},
         body = req_body,
   })
end

local function authenticate()
   local data = downstream.get_body_table()
   local req_body = cjson.encode({
         p_username = data.username,
         p_password = data.password
   })
   local login_res = app_http.req_pgst({
         path = "/rpc/check_username_password",
         method = "POST",
         body = req_body,
   })
   if login_res.err then
      ngx.status = 401
      ngx.say(login_res.err)
      return
   end
   local uuid = string.gsub(
      cjson.decode(login_res.body), "%s", ""
   )
   if string.len(uuid) == 0 then
      ngx.status = 401
      ngx.say(cjson.encode("invalid credentials"))
      return
   end
   -- generate a jwt...
   respond_new_session()
end

-- module
local M = {}
M.authenticate = authenticate
M.init_user = init_user
return M
