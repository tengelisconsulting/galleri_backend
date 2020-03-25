local cjson = require "cjson"
local http = require "resty.http"

local conf = require "lua/conf"


local PGST_HOST = conf.get_pgst_host()
local PGST_PORT = conf.get_pgst_port()

local function req(spec)
   local httpc = http:new()
   httpc:set_timeout(500)
   httpc:connect(spec.host, spec.port)
   local res, err = httpc:request({
         method = spec.method,
         path = spec.path,
         headers = spec.headers,
         body = spec.body
   })
   if not res then
      ngx.say("req failed: ", err)
      return {
         status = 502,
         err = err,
         body = nil
      }
   end
   local body, err = res:read_body()
   if err then
      ngx.say("failed to read body: ", err)
      return {
         status = 502,
         err = err,
         body = nil
      }
   end
   return {
      status = res.status,
      err = nil,
      body = body
   }
end

local function proxy_request(host, port, changes)
   ngx.log(ngx.NOTICE, cjson.encode(ngx.req.get_headers()))
   local body = changes.body
   if not body then
      ngx.req.read_body()
      body = ngx.req.get_body_data()
   end
   local req_spec = {
      host = host,
      port = port,
      method = changes.method or ngx.req.get_method(),
      path = changes.path or ngx.var.request_uri,
      headers = changes.headers or ngx.req.get_headers(),
      body = body,
   }
   local res = req(req_spec)
   ngx.status = res.status
   if res.err then
      ngx.say(res.err)
      return
   end
   ngx.log(ngx.NOTICE, res.body)
   ngx.say(res.body)
end

local function proxy_pgst(changes)
   proxy_request(PGST_HOST, PGST_PORT, changes)
end

local M = {}
M.req = req
M.proxy_pgst = proxy_pgst
M.proxy_request = proxy_request
return M
