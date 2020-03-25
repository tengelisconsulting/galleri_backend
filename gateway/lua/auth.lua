local cjson = require "cjson"

local app_http = require "lua/app_http"
local downstream = require "lua/downstream"


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
   ngx.say(login_res.body)
end

-- module
local M = {}
M.authenticate = authenticate
M.init_user = init_user
return M
