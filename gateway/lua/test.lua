local cjson = require "cjson"

local app_cors = require "lua/app_cors"
local downstream = require "lua/downstream"
local log = require "lua/log"
local ez = require "lua/ez"


local function do_test()
   app_cors.set_cors_headers()
   local req_body = cjson.encode({user_id = "xxxx"})
   local token_res, err = ez.r({"AUTH", "/token/new/refresh", req_body})
   local token = token_res.token
   log.info("got token %s", token)
   ngx.say(cjson.encode("hey"))
end

local M = {}
M.do_test = do_test
return M
