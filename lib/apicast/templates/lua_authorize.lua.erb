local random = require 'resty.random'
local cjson = require 'cjson'
local ts = require 'threescale_utils'
local redis = require 'resty.redis'
local red = redis:new()

function check_return_url(client_id, return_url)
  local res = ngx.location.capture("/_threescale/redirect_uri_matches",
    { vars = { red_url = return_url ,
    client_id = client_id }})
  return (res.status == 200)
end

-- returns 2 values: ok, err
-- if ok == true, err is undefined
-- if ok == false, err contains the errors
function authorize(params)
   -- scope is required because the provider needs to know which plan
   -- is the user trying to log to
   local required_params = {'client_id', 'redirect_uri', 'response_type', 'scope'}

  if ts.required_params_present(required_params, params) and params["response_type"] == 'code' and check_return_url(params.client_id, params.redirect_uri) then
    redirect_to_login(params)
    elseif params["response_type"] ~= 'code' then
      return false, 'unsupported_response_type'
    else
      ngx.log(0, ts.dump(params))
      return false, 'invalid_request'
    end
    ts.error("we should never be here")
  end

-- returns a unique string for the client_id. it will be short lived
function nonce(client_id)
  return ts.sha1_digest(tostring(random.bytes(20, true)) .. "#login:" .. client_id)
end

function generate_access_token(client_id)
  return ts.sha1_digest(tostring(random.bytes(20, true)) .. client_id)
end

-- redirects_to the login form of the API provider with a secret
-- 'state' which will be used when the form redirects the user back to
-- this server.
function redirect_to_login(params)
  local n = nonce(params.client_id)
  ngx.log(0, "redirect_to_login")

  params.scope = params.scope
  ts.connect_redis(red)
  local pre_token = generate_access_token(params.client_id)

  local ok, err = red:hmset(ngx.var.service_id .. "#tmp_data:".. n,
    {client_id = params.client_id,
    redirect_uri = params.redirect_uri,
    plan_id = params.scope,
    pre_access_token = pre_token})

  if not ok then
    ts.error(ts.dump(err))
  end

  -- TODO: If the login_url has already the parameter state bad
  -- things are to happen
  ngx.redirect(ngx.var.login_url .. "?scope=".. params.scope .. "&state=" .. n .. "&tok=".. pre_token)
  ngx.exit(ngx.HTTP_OK)
end

local params = ngx.req.get_uri_args()
local _ok, a_err = authorize(params)

if not a_ok then
  ngx.redirect(ngx.var.login_url .. "?scope=" .. params.scope .. "&state=" .. (params.state or '') .. "&error=" .. a_err)
end