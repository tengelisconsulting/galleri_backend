local app_cors = require "lua/app_cors"


local function do_test()
   app_cors.set_cors_headers()
   ngx.say("hey")
end

local M = {}
M.do_test = do_test
return M
