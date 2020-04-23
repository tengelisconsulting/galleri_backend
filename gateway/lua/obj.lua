local app_http = require "lua/app_http"

local function get_access_url(obj_id, access_op)
   return app_http.proxy_http_zmq({
         method = "GET",
         path = "/aws-url/access/" .. access_op .. "?objId=" .. obj_id,
   })
end


local M = {}
M.get_access_url = get_access_url
return M
