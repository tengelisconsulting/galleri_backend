local cjson = require "cjson"

local app_http = require "lua/app_http"
local downstream = require "lua/downstream"


local function set_aws_req()
   local method = ngx.req.get_method()
   local url = ngx.var.arg_url
   local headers_res = app_http.req_http_zmq({
         method = "GET",
         path = "/aws/headers-for-req?method=" .. method
            .. "&url=" .. url,
         body = nil
   })
   ngx.log(ngx.INFO, headers_res.status)
   if headers_res.err then
      ngx.log(ngx.ERR, "failed to get aws headers")
      ngx.fail(500)
   end
   local new_headers = cjson.decode(headers_res.body).aws_headers
   for k, v in pairs(new_headers) do
      ngx.req.set_header(k, v)
      -- ngx.header[k] = v
   end
   ngx.req.set_uri_args({})     -- I don't need any for now
   -- ngx.redirect("http://127.0.0.1:9000/galleri-storage-1/xxx")
end


local M = {}
M.set_aws_req = set_aws_req
return M
