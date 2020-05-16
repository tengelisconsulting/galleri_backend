local cjson = require "cjson"


local function die(status, msg)
   ngx.status = status
   ngx.say(cjson.encode({
                 err = msg,
   }))
   ngx.exit(status)
end

local function success(msg)
   ngx.status = 200
   ngx.say(cjson.encode(msg))
   ngx.exit(200)
end


local M = {}
M.die = die
M.success = success
return M
