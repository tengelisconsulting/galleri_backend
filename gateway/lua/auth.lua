local cjson = require "cjson"

local app_http = require "lua/app_http"
local log = require "lua/log"
local respond = require "lua/respond"
local ez = require "lua/ez"

local TOKEN_CAPTURE = "Bearer: (.*)"


local function authenticate_fail(err_msg)
   local status = 401
   local msg = "request authorizaation failed - " .. err_msg
   respond.die(401, msg)
end

local function authorize_fail(err_msg)
   local msg = "request authorization failed - " .. err_msg
   log.err(msg)
   respond.die(403, msg)
end

local function authenticate_req()
   local auth_header = ngx.var.http_authorization
   if not auth_header then
      authenticate_fail("no auth header")
      return
   end
   local _, _, token = string.find(auth_header, TOKEN_CAPTURE)
   if not token then
      authenticate_fail("bad auth header")
      return
   end
   -- get user id from token
   local session_res, err = ez.r("SESSION", "/token/parse", {
                                    token = token,
                                    is_refresh = false
   })
   if err then
      authenticate_fail("token verification failed")
      return
   end
   local user_id = session_res.claims.user_id
   ngx.var.user_id = user_id
   ngx.req.set_header("user-id", user_id)
   return user_id
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

local function authorize_owner(user_id, obj_id)
   local auth_res = app_http.req_sys_pgst({
         path = "/rpc/check_session_owns",
         method = "POST",
         body = cjson.encode({
               p_user_id = user_id,
               p_obj_id = obj_id,
         }),
         headers = headers
   })
   if auth_res.err then
      authorize_fail("failed to determine session ownership")
      return
   end
   local is_success = cjson.decode(auth_res.body)
   if is_success == true then
      return true
   end
   authorize_fail("session requested access to an object it doesn't own")
end

local M = {}
M.authorize_obj_access = authorize_obj_access
M.authenticate_req = authenticate_req
M.authorize_owner = authorize_owner
return M
