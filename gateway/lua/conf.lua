local os = require "os"


-- private
local ALLOWED_ORIGIN = os.getenv("ALLOWED_ORIGIN")
local PGST_HOST = os.getenv("PGST_HOST")
local PGST_PORT = tonumber(os.getenv("PGST_PORT"))
local HTTP_ZMQ_HOST = os.getenv("HTTP_ZMQ_HOST")
local HTTP_ZMQ_PORT = tonumber(os.getenv("HTTP_ZMQ_HTTP_PORT"))
local OBJ_STORAGE_HOST = os.getenv("OBJ_STORAGE_HOST")
local OBJ_STORAGE_BUCKET = os.getenv("OBJ_STORAGE_BUCKET")


-- public
local function get_allowed_origin()
   return ALLOWED_ORIGIN
end

local function get_pgst_host()
   return PGST_HOST
end

local function get_pgst_port()
   return PGST_PORT
end

local function get_http_zmq_host()
   return HTTP_ZMQ_HOST
end

local function get_http_zmq_port()
   return HTTP_ZMQ_PORT
end

local function get_obj_storage_endpoint()
   return OBJ_STORAGE_HOST .. "/" .. OBJ_STORAGE_BUCKET
end

-- module
local M = {}
M.get_allowed_origin = get_allowed_origin
M.get_http_zmq_host = get_http_zmq_host
M.get_http_zmq_port = get_http_zmq_port
M.get_obj_storage_endpoint = get_obj_storage_endpoint
M.get_pgst_host = get_pgst_host
M.get_pgst_port = get_pgst_port
return M
