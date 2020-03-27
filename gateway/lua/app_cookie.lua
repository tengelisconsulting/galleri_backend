local ck = require "resty.cookie"


local function do_work(fn)
   local cookie, err = ck:new()
   if not cookie then
      ngx.log(ngx.ERR, err)
      return nil, err
   end
   return fn(cookie)
end

-- public
local function set(spec)
   local function exec(cookie)
      return cookie:set(spec)
   end
   return do_work(exec)
end


local M = {}
M.set = set
return M
