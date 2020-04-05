local app_cors = require "lua/app_cors"
local downstream = require "lua/downstream"
local log = require "lua/log"


local function do_test()
   app_cors.set_cors_headers()
   local body = downstream.get_body_string()
   log.info("req body: %s", body)
   ngx.say("hey")
end

local M = {}
M.do_test = do_test
return M
