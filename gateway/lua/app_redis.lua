local redis = require "resty.redis"

local conf = require "lua/conf"
local log = require "lua/log"


-- private
local function do_work(cb)
   local red = redis:new()
   -- red:set_timeouts(10000, 10000, 10000)
   local ok, err = red:connect(conf.REDIS_HOST, conf.REDIS_PORT)
   if not ok then
      log.err("failed to init redis client: %s", err)
      return nil, err
   end
   local res, err = cb(red)
   local keep_ok, keep_err = red:set_keepalive(10000, 100)
   if not keep_ok then
      log.err("failed to set keepalive: %s", keep_err)
   end
   return res, err
end

-- public
local function set(key, val)
   local function _set(red)
      return red:set(key, val)
   end
   return do_work(_set)
end

local function get(key)
   local function _get(red)
      return red:get(key, val)
   end
   return do_work(_get)
end

local M = {}
M.get = get
M.set = set
return M
