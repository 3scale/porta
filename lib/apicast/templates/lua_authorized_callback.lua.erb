-- authorized_callback.lua

-- Once the client has been authorized by the API provider in their
-- login, the provider is supposed to send the client (via redirect)
-- to this endpoint, with the same status code that we sent him at the
-- moment of the first redirect

local random = require 'resty.random'
local cjson = require 'cjson'
local ts = require 'threescale_utils'
local redis = require 'resty.redis'
local red = redis:new()

local ok, err
local params = ngx.req.get_uri_args()

if ts.required_params_present({'state'}, params) then
  ts.connect_redis(red)
  local tmp_data = ngx.var.service_id .. "#tmp_data:".. params.state
  ok , err = red:exists(tmp_data)
  if 0 == ok then
    -- TODO: Redirect? to the initial state?
    ts.missing_args("state does not exist. Probably expired")
  end
  ok, err = red:hgetall(tmp_data)
  if not ok then
    ts.error("no values for tmp_data hash: ".. ts.dump(err))
  end

  local client_data = red:array_to_hash(ok)  -- restoring client data

  -- Delete the tmp_data:
  red:del(tmp_data)

  local code = ts.sha1_digest(tostring(random.bytes(20, true)) .. "#code:" .. client_data.client_id)
  ok, err =  red:hmset("c:".. code, {client_id = client_data.client_id,
    client_secret = client_data.secret_id,
    redirect_uri = client_data.redirect_uri,
    pre_access_token = client_data.pre_access_token,
    code = code })

  ok, err =  red:expire("c:".. code , 60 * 10) -- code expires in 10 mins

  if not ok then
    ngx.say("failed to hmset: ", err)
    ngx.exit(ngx.HTTP_OK)
  end

  ngx.req.set_header("Content-Type", "application/x-www-form-urlencoded")
  return ngx.redirect(client_data.redirect_uri .. "?code="..code .. "&state=" .. (client_data.state or ""))
else
  ts.missing_args("{ 'error': '".. "invalid_client_data from login form" .. "'}")
end
