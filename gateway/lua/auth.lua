local cjson = require "cjson"

local app_http = require "lua/app_http"
local ez = require "lua/ez"
local log = require "lua/log"
local respond = require "lua/respond"


local function authorize_fail(err_msg)
   local msg = "request authorization failed - " .. err_msg
   log.err(msg)
   respond.die(403, msg)
end


local function get_access_code(access_op)
   if access_op == "read" then
      return "r"
   else
      return "w"
   end
end


local function authorize_obj_access(user_id, obj_id, access_op)
   local res, err = ez.r("AUTH", "/verify/user-id", {
                            obj_id = obj_id,
                            op = get_access_code(access_op),
                            user_id = user_id,
   })
   if err then
      authorize_fail(string.format("user %s does not have %s permission on %s",
                                   user_id, access_op, obj_id))
      return
   end
end

local M = {}
M.authorize_obj_access = authorize_obj_access
return M
