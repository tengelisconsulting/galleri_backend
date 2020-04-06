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
   -- you have to load the file to this server,
   -- then upload it to aws yourself, after returning 200
   -- on the original upload
   local init_url = string.format("/rpc/%s_create", obj_type)
   local delete_url = string.format("/rpc/%s_delete", obj_type)
   local update_url = string.format("/rpc/%s_update", obj_type)
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
   local req_body = downstream.get_body_string()
   -- put the body into redis...
   local upload_init_res = app_http.req_http_zmq({
         method = "POST",
         path = "/upload/obj-storage",
         -- path = string.format("/upload/obj-storage/%s", obj_id),
         body = cjson.encode(""),
   })
   if upload_init_res.err then
      log.err("failed to save object %s to storage - will remove record", obj_id)
      local del_res = app_http.req_sys_pgst({
            path = delete_url,
            method = "POST",
            body = cjson.encode({
                  p_obj_id = obj_id
            }),
      })
      if del_res.err then
         log.err("FAILED TO DELETE OBJECT %s - THIS OBJECT WILL EXIST IN STORAGE BUT IS NOT TRACKED", obj_id)
      end
      respond.die(500, "obj storage failure")
      return
   end
   -- update the href in the zmq handler
   respond.success(string.format("object %s created", obj_id))
end

local function delete_obj(obj_type, obj_id)
   local aws_res, err_code = aws.req_aws(obj_id, "DELETE")
   if err_code then
      respond.die(err_code, "object storage delete failed")
   end
   local delete_url = string.format("/rpc/%s_delete", obj_type)
   return app_http.proxy_sys_pgst({
         path = delete_url,
         method = "POST",
         body = cjson.encode({
               p_obj_id = obj_id
         }),
   })
end


local OBJECTS_READ_OK = {
   image = true
}
local OBJECTS_CREATE_OK = {
   image = true
}
local OBJECTS_DELETE_OK = {
   image = true
}

-- public
local function access_obj(obj_type, obj_id)
   local function bad_obj_method()
      respond.die(
         400, "method %s not supported for object type %s",
         method, obj_type
      )
   end
   local method = ngx.req.get_method()
   if method == "GET" then
      if not OBJECTS_READ_OK[obj_type] then
         bad_obj_method()
         return
      end
      return get_obj(obj_type, obj_id)
   end
   if method == "PUT" then
      if not OBJECTS_CREATE_OK[obj_type] then
         bad_obj_method()
         return
      end
      return put_obj(obj_type, obj_id)
   end
   if method == "DELETE" then
      if not OBJECTS_DELETE_OK[obj_type] then
         bad_obj_method()
         return
      end
      return delete_obj(obj_type, obj_id)
   end
   ngx.exit(405)
end


local M = {}
M.access_obj = access_obj
return M
