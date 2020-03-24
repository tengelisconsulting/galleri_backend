local http = require "resty.http"


local function req(
      host,
      port,
      method,
      path,
      headers
                  )
   local httpc = http:new()
   httpc:set_timeout(500)
   httpc:connect(host, port)
   local res, err = httpc:request({
         method = method,
         path = path,
         headers = headers
         -- headers = {
         --    ["Host"] = "example.com",
         -- },
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

local M = {}
M.req = req
return M
