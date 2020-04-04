local cjson = require "cjson"

local app_http = require "lua/app_http"
local conf = require "lua/conf"
local downstream = require "lua/downstream"
local log = require "lua/log"


local OBJ_STORAGE_ENDPOINT = conf.OBJ_STORAGE_HOST .. "/"
   ..conf.OBJ_STORAGE_BUCKET
local OBJ_STORAGE_PATH = "/" .. conf.OBJ_STORAGE_BUCKET

local function get_target_url(obj_id)
   return "https://" .. OBJ_STORAGE_ENDPOINT .. "/" .. obj_id
end


local function req_aws(obj_id, method, req_body)
   local target_url = get_target_url(obj_id)
   local encoded_url = ngx.escape_uri(target_url)
   local headers_res = app_http.req_http_zmq({
         method = "GET",
         path = "/aws/headers-for-req?method=" .. method
            .. "&url=" .. encoded_url,
         body = nil
   })
   if headers_res.err then
      ngx.log(ngx.ERR, "failed to get aws headers")
      return nil, 500
   end
   local aws_headers = cjson.decode(headers_res.body).aws_headers
   local aws_req = {
      method = method,
      path = OBJ_STORAGE_PATH .. "/" .. obj_id,
      headers = aws_headers,
      body = req_body,
      ssl_verify = false
   }
   local aws_res, err = app_http.one_and_done(target_url, aws_req, 2000)
   if err then
      log.err("failed to handle req to aws - %s", err)
      return nil, 500
   end
   if 200 == aws_res.status then
      return aws_res, nil
   end
   log.err("req to aws received error code - %s", aws_res.status)
   return nil, aws_res.status
end

local M = {}
M.req_aws = req_aws
return M
