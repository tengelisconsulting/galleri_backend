local cjson = require "cjson"


-- public
local function get_body_table()
   ngx.req.read_body()
   return cjson.decode(ngx.req.get_body_data())
end

local function get_body_string()
   ngx.req.read_body()
   return ngx.req.get_body_data()
end


local M = {}
M.get_body_table = get_body_table
M.get_body_string = get_body_string
return M
