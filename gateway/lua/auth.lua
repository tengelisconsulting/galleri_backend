local app_http = require "lua/app_http"
local conf = require "lua/conf"
local cjson = require "cjson"


-- public
local function login(username, password)
   ngx.req.read_body()
   local data = cjson.decode(ngx.req.get_body_data())
   ngx.log(ngx.NOTICE, data.username)
   ngx.log(ngx.NOTICE, data.password)
   local res = app_http.req(
      conf.get_pgst_host(),
      conf.get_pgst_port(),
      "GET", "/", {}
   )
   ngx.status = res.status
   if res.err then
      ngx.say(res.err)
      return
   end
   ngx.say(res.body)
end

-- module
local M = {}
M.login = login
return M
