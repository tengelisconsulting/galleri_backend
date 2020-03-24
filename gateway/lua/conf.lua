local os = require "os"


-- private
local PGST_HOST = os.getenv("PGST_HOST")
local PGST_PORT = tonumber(os.getenv("PGST_PORT"))

-- public
local function get_pgst_host()
   return PGST_HOST
end

local function get_pgst_port()
   return PGST_PORT
end

-- module
local M = {}
M.get_pgst_host = get_pgst_host
M.get_pgst_port = get_pgst_port
return M
