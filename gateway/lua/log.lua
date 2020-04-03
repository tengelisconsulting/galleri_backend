
local function log(level, template, ...)
   local s = string.format(template, ...)
   ngx.log(level, s)
end


local function info(s, ...)
   log(ngx.INFO, s, ...)
end

local function err(s, ...)
   log(ngx.ERR, s, ...)
end

local function dbg(s, ...)
   log(ngx.DEBUG, s, ...)
end

local M = {}
M.info = info
M.err = err
M.dbg = dbg
return M
