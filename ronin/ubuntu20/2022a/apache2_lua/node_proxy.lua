--CNH local user_map = require 'ood.user_map'
local proxy    = require 'proxy'
--CNH local http     = require 'ood.http'

--[[
  node_proxy_handler

  Maps an authenticated user to a system user. Then proxies user's traffic to a
  backend node with the host and port specified in the request URI.
--]]
function node_proxy_handler(r)
  -- read in OOD specific settings defined in Apache config
  --CNH local user_map_cmd = r.subprocess_env['OOD_USER_MAP_CMD']
  --CNH local user_env     = r.subprocess_env['OOD_USER_ENV']
  --CNH local map_fail_uri = r.subprocess_env['OOD_MAP_FAIL_URI']

  -- read in <LocationMatch> regular expression captures
  --CNH local host = r.subprocess_env['MATCH_HOST']
  local port = r.subprocess_env['MATCH_PORT']
  --CNH local uri  = r.subprocess_env['MATCH_URI']
  local uri = "/"

  -- get the system-level user name
  --CNH local user = user_map.map(r, user_map_cmd, user_env and r.subprocess_env[user_env] or r.user)
  --CNH if not user then
  --CNH   if map_fail_uri then
  --CNH     return http.http302(r, map_fail_uri .. "?redir=" .. r:escape(r.unparsed_uri))
  --CNH   else
  --CNH     return http.http404(r, "failed to map user (" .. r.user .. ")")
  --CNH   end
  --CNH end

  -- generate connection object used in setting the reverse proxy
  local conn = {}
  --CNH conn.user = user
  conn.server = "localhost" .. ":" .. port
  conn.uri = uri and (r.args and (uri .. "?" .. r.args) or uri) or r.unparsed_uri

  -- setup request for reverse proxy
  proxy.set_reverse_proxy(r, conn)

  -- handle if backend server is down
  r:custom_response(503, "Failed to connect to " .. conn.server)

  -- let the proxy handler do this instead
  return apache2.DECLINED
end
