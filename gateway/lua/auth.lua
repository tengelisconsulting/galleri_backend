local cjson = require "cjson"

local app_http = require "lua/app_http"
local log = require "lua/log"
local respond = require "lua/respond"


local function authorize_fail(err_msg)
   local msg = "request authorization failed - " .. err_msg
   log.err(msg)
   respond.die(403, msg)
end

local function authorize_obj_access(user_id, obj_id, access_op)
   local perm_res = app_http.req_pub_pgst({
         path = string.format("/obj_op_permitted?obj_id=eq.%s", obj_id),
         method = "GET",
   })
   if perm_res.err then
      authorize_fail("failed to determine object permissions")
      return
   end
   local permission_rows = cjson.decode(perm_res.body)
   if not permission_rows[1] then
      -- the object does not exist, so there are no permissions on it
      return
   end
   local permissions = permission_rows[1]
   if access_op == "read" then
      if not permissions.read_access then
         authorize_fail(
            string.format("user does not have read access to obj %s",
                          user_id, obj_id))
      end
      return
   end
   -- all other ops require write access
  if not permissions.write_access then
     authorize_fail(
        string.format("user does not have write access to obj %s",
                      user_id, obj_id))
  end
end

local M = {}
M.authorize_obj_access = authorize_obj_access
return M
