local auth = require "lua/auth"
local respond = require "lua/respond"


local function get_anon_collection_link(
      collection_id, exp_ts)
   local ops = {
      { method = "GET",
        url = string.format(
           [[/db/image_collection_public\?collection_id=eq.%s]],
           collection_id) },
      { method = "GET",
        url = string.format(
           [[/db/image_public\?collection_id=eq.%s.*]], collection_id
      )}
   }
   local claims = auth.get_access_hash(exp_ts, ops)
   respond.success(claims)
end


local M = {}
M.get_anon_collection_link = get_anon_collection_link
return M
