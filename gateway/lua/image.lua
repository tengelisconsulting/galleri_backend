local cjson = require "cjson"

local log = require "lua/log"


local function init_image(user_id, obj_id)
   local init_res = app_http.req_sys_pgst({
         path = "/rpc/image_create",
         method = "POST",
         body = cjson.encode({
               p_user_id = user_id,
               p_obj_id = obj_id
         }),
   })
   if init_res.err then
      log.error("failed to init image %s", obj_id)
      return nil, init_res.status
   end
   return init_res.body, nil
end

local function delete_image(obj_id)
   local init_res = app_http.req_sys_pgst({
         path = "/rpc/image_delete",
         method = "POST",
         body = cjson.encode({
               p_obj_id = obj_id
         }),
   })
   if init_res.err then
      log.error("failed to init image %s", obj_id)
      return nil, init_res.status
   end
   return init_res.body, nil
end


local M = {}
M.init_image = init_image
return M
