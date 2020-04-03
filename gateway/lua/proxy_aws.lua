local cjson = require "cjson"

local app_http = require "lua/app_http"
local conf = require "lua/conf"
local downstream = require "lua/downstream"


local OBJ_STORAGE_ENDPOINT = conf.get_obj_storage_endpoint()

local function get_target_url(obj_id)
   return "https://" .. OBJ_STORAGE_ENDPOINT .. "/" .. obj_id
end

local function set_aws_req()
   local obj_id = ngx.var.obj_id
   local method = ngx.req.get_method()
   local target_url = get_target_url(obj_id)
   ngx.var.target_url = target_url
   ngx.log(ngx.INFO, "target url")
   ngx.log(ngx.INFO, target_url)
   local encoded_url = ngx.escape_uri(target_url)
   local headers_res = app_http.req_http_zmq({
         method = "GET",
         path = "/aws/headers-for-req?method=" .. method
            .. "&url=" .. encoded_url,
         body = nil
   })
   if headers_res.err then
      ngx.log(ngx.ERR, "failed to get aws headers")
      ngx.fail(500)
   end
   local new_headers = cjson.decode(headers_res.body).aws_headers
   for k, v in pairs(new_headers) do
      ngx.req.set_header(k, v)
   end
   ngx.req.set_uri_args({})     -- I don't need any for now
end


local M = {}
M.set_aws_req = set_aws_req
return M
