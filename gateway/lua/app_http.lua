local cjson = require "cjson"
local http = require "resty.http"

local conf = require "lua/conf"


local PGST_HOST = conf.get_pgst_host()
local PGST_PORT = conf.get_pgst_port()
local HTTP_ZMQ_HOST = conf.get_http_zmq_host()
local HTTP_ZMQ_PORT = conf.get_http_zmq_port()


local function req(host, port, spec, timeout)
   if not timeout then
      timeout = 500
   end
   local httpc = http:new()
   httpc:set_timeout(timeout)
   local ok, err = httpc:connect(host, port)
   local res, err = httpc:request({
         method = spec.method,
         path = spec.path,
         headers = spec.headers,
         body = spec.body
   })
   if err then
      ngx.log(ngx.ERR, "req failed: " .. err)
      return {
         status = 502,
         err = err,
         body = nil
      }
   end
   local body, err = res:read_body()
   if err then
      ngx.log(ngx.ERR, "failed to read body: " .. err)
      return {
         status = 502,
         err = err,
         body = nil
      }
   end
   if 200 <= res.status and res.status < 400 then
      err = nil
   else
      err = "http return code not OK"
   end
   return {
      status = res.status,
      err = err,
      body = body
   }
end

local function one_and_done(
      url,
      spec,
      con_timeout
                           )
   if not con_timeout then
      con_timeout = 500
   end
   if not spec.keepalive_ms then
      spec.keepalive_ms = 60000
   end
   if not spec.keepalive_pool then
      spec.keepalive_pool = 10
   end
   local httpc = http:new()
   httpc:set_timeout(con_timeout)
   return httpc:request_uri(url, spec) -- res, err
end

local function proxy_request(host, port, changes)
   local body = changes.body
   if not body then
      ngx.req.read_body()
      body = ngx.req.get_body_data()
   end
   local req_spec = {
      method = changes.method or ngx.req.get_method(),
      path = changes.path or ngx.var.request_uri,
      headers = changes.headers or ngx.req.get_headers(),
      body = body,
   }
   local res = req(host, port, req_spec)
   ngx.status = res.status
   if res.err then
      ngx.say(
         cjson.encode({
               err = res.err
         })
      )
      return
   end
   ngx.say(res.body)
end

local function req_pgst(spec)
   return req(PGST_HOST, PGST_PORT, spec)
end

local function req_http_zmq(spec)
   return req(HTTP_ZMQ_HOST, HTTP_ZMQ_PORT, spec)
end

local function proxy_pgst(changes)
   proxy_request(PGST_HOST, PGST_PORT, changes)
end


local M = {}
M.one_and_done = one_and_done
M.proxy_pgst = proxy_pgst
M.proxy_request = proxy_request
M.req = req
M.req_http_zmq = req_http_zmq
M.req_pgst = req_pgst
return M
