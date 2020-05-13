local cjson = require "cjson"

local app_http = require "lua/app_http"
local ez = require "lua/ez"
local log = require "lua/log"
local respond = require "lua/respond"


local function get_access_url(obj_id, access_op)
   local path = string.format("/access/%s", access_op)
   local res, err = ez.r("AWS", path, {obj_id = obj_id})
   log.info("got res: %s", res)
   if err then
      respond.die(401, "AWS url gneeration failed")
   end
   ngx.say(cjson.encode(res))
end


local M = {}
M.get_access_url = get_access_url
return M
