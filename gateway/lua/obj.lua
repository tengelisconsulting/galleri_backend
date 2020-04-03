local cjson = require "cjson"

local aws = require "lua/aws"
local log = require "lua/log"


-- private
local function get_obj(obj_id)
   local res, err_code = aws.req_aws(obj_id, "GET", nil)
   if err_code then
      ngx.status = err_code
      ngx.say(cjson.encode({
                    err = "obj storage failure"
      }))
      ngx.exit(err_code)
      return
   end
   ngx.status = res.status
   ngx.say(res.body)
end

         -- body = downstream.get_body_string()

-- public
local function access_obj(obj_id)
   local method = ngx.req.get_method()
   if method == "GET" then
      return get_obj(obj_id)
   end
end


local function create_obj()
end


local M = {}
M.access_obj = access_obj
return M
