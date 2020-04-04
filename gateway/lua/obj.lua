local cjson = require "cjson"

local app_http = require "lua/app_http"
local aws = require "lua/aws"
local downstream = require "lua/downstream"
local image = require "lua/image"
local log = require "lua/log"
local respond = require "lua/respond"


-- private
local function get_obj(obj_type, obj_id)
   local res, err_code = aws.req_aws(obj_id, "GET", nil)
   if err_code then
      respond.die(err_code, "obj storage failure")
      return
   end
   ngx.status = res.status
   ngx.say(res.body)
end

local function put_obj(obj_type, obj_id)
   local init_url = "/rpc/" .. obj_type .. "_create"
   local delete_url = "/rpc/" .. obj_type .. "_delete"
   local init_res = app_http.req_sys_pgst({
         path = init_url,
         method = "POST",
         body = cjson.encode({
               p_user_id = ngx.var.user_id,
               p_obj_id = obj_id
         }),
   })
   if init_res.err then
      log.err("failed to init object record for %s - %s",
              obj_id, init_res.body)
      respond.die(500, "failed to init object record")
      return
   end
   local aws_res, err_code = aws.req_aws(
      obj_id, "PUT", downstream.get_body_string()
   )
   if err_code then
      log.err("failed to save object %s - will remove record", obj_id)
      local del_res = app_http.req_sys_pgst({
            path = delete_url,
            method = "POST",
            body = cjson.encode({
                  p_obj_id = obj_id
            }),
      })
      if del_res.err then
         log.err("FAILED TO DELETE OBJECT %s - THIS WILL BECOME A GHOST OBJECT", obj_id)
      end
      respond.die(err_code, "obj storage failure")
      return
   end
   respond.success("object " .. obj_id .. " created")
end

local function delete_obj(obj_type, obj_id)
   -- first delete from aws...
   local delete_url = "/rpc/" .. obj_type .. "_delete"
   return app_http.proxy_sys_pgst({
         path = delete_url,
         method = "POST",
         body = cjson.encode({
               p_obj_id = obj_id
         }),
   })
end

-- public
local function access_obj(obj_type, obj_id)
   local method = ngx.req.get_method()
   if obj_type ~= "image" then  -- add others with time
      respond.die(400, "unrecognized object type: " .. obj_type)
      return
   end
   if method == "GET" then
      return get_obj(obj_type, obj_id)
   end
   if method == "PUT" then
      return put_obj(obj_type, obj_id)
   end
   if method == "DELETE" then
      return delete_obj(obj_type, obj_id)
   end
   ngx.exit(405)
end


local M = {}
M.access_obj = access_obj
return M
