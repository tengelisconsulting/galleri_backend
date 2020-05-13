local os = require "os"

local log = require "lua/log"


local M = {}

M.ALLOWED_ORIGIN = os.getenv("ALLOWED_ORIGIN")

M.EZ_INPUT_HOST = os.getenv("EZ_INPUT_HOST")
M.EZ_INPUT_PORT = tonumber(os.getenv("EZ_INPUT_PORT"))

-- get rid o dese
M.HTTP_ZMQ_HOST = os.getenv("HTTP_ZMQ_HOST")
M.HTTP_ZMQ_PORT = tonumber(os.getenv("HTTP_ZMQ_HTTP_PORT"))

M.OBJ_STORAGE_HOST = os.getenv("OBJ_STORAGE_HOST")
M.OBJ_STORAGE_BUCKET = os.getenv("OBJ_STORAGE_BUCKET")
M.PUB_PGST_HOST = os.getenv("PUB_PGST_HOST")
M.PUB_PGST_PORT = tonumber(os.getenv("PUB_PGST_PORT"))
M.SYS_PGST_HOST = os.getenv("SYS_PGST_HOST")
M.SYS_PGST_PORT = tonumber(os.getenv("SYS_PGST_PORT"))

-- don't need
M.REDIS_HOST = os.getenv("REDIS_HOST")
M.REDIS_PORT = tonumber(os.getenv("REDIS_PORT"))

return M
-- just don't rewrite these...
