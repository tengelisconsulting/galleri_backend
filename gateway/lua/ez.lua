local cjson = require "cjson"
local ez_client = require "ez_client"

local conf = require "lua/conf"


local requester = ez_client.new_requester(
   conf.EZ_INPUT_HOST, conf.EZ_INPUT_PORT
)

local function r(frames, opts)
   local res, err = requester(frames, opts)
   if err then
      return ok, err
   end
   local ok, body = unpack(res)
   if ok == "ERR" then
      return nil, body          -- body is error code
   end
   return cjson.decode(body), nil
end

local M = {}
M.r = r
return M
