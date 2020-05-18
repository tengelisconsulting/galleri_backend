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


local function authorize_anon_obj_access(
      obj_id, access_op, exp_ts, ops, claims_hash)
   if not (type(ops) == "table") then
      ops = {ops}
   end
   local claims = {
      obj_id = obj_id,
      exp_ts = exp_ts,
      ops = ops,
   }
   local res, err = ez.r("AUTH", "/verify/anon", {
                            obj_id = obj_id,
                            op = get_access_code(access_op),
                            claims = claims,
                            claims_hash_b64 = claims_hash,
   })
   if err then
      authorize_fail(string.format("claims %s failed to authorize",
                                   log.table_print(claims)))
      return
   end
end


local function get_access_hash(exp_ts, ops)
   local res, err = ez.r("AUTH", "/access-hash", {
                            exp_ts = exp_ts,
                            ops = ops,
   })
   if err then
      respond.die(tonumber(err), "failed to issue hash")
   end
   return res
end


local M = {}
M.authorize_anon_obj_access = authorize_anon_obj_access
M.authorize_obj_access = authorize_obj_access
M.get_access_hash = get_access_hash
return M
