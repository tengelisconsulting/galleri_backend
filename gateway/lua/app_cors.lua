local conf = require "lua/conf"


local function set_cors_headers()
   if ngx.req.get_method() == "OPTIONS" then
      ngx.header["Access-Control-Allow-Credentials"] = "true"
      ngx.header["Access-Control-Allow-Origin"] = conf.ALLOWED_ORIGIN;
      ngx.header["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS" ;
      ngx.header["Access-Control-Allow-Headers"] = "Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With,Referer,Sec-Fetch-Dest";
      ngx.header["Access-Control-Expose-Headers"] = "Content-Length,Content-Range";
      ngx.header["Access-Control-Max-Age"] = "1728000";
      ngx.header["Content-Type"] = "text/plain; charset=utf-8";
      ngx.header["Content-Length"] = "0";
      ngx.exit(204)
   else
      ngx.header["Access-Control-Allow-Credentials"] = "true"
      ngx.header["Access-Control-Allow-Origin"] = conf.ALLOWED_ORIGIN;
   end
end


local M = {}
M.set_cors_headers = set_cors_headers
return M
