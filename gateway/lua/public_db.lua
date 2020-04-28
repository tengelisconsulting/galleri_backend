local respond = require "lua/respond"


local PUBLIC_OBJECTS = {
   logon_names = true,
}

local function ensure_public(obj_name)
   if not PUBLIC_OBJECTS[obj_name] then
      respond.die(401, "resource is not public")
   end
end


local M = {}
M.ensure_public = ensure_public
return M
