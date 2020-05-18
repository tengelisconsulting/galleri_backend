local cjson = require "cjson"

local app_cors = require "lua/app_cors"
local downstream = require "lua/downstream"
local log = require "lua/log"
local ez = require "lua/ez"


local function do_test()
   app_cors.set_cors_headers()
   local anon_token = ngx.var.http_authorization
   log.info("anon token: %s", anon_token)
   local res, err = ez.r("AUTH", "/verify/anon", {
                            op = {
                               method = "GET",
                               url = "/test/hi",
                            },
                            claims_token = anon_token,
   })
   log.info("--------------------- OK ? %s", res)
   ngx.say(cjson.encode("hey"))
end

local M = {}
M.do_test = do_test
return M
