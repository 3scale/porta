-- threescale_utils.lua
local M = {} -- public interface

-- private
-- Logging Helpers
function M.show_table(t, ...)
  local indent = 0 --arg[1] or 0
  local indentStr=""
  for i = 1,indent do 
    indentStr=indentStr.."  " 
  end
  
  for k,v in pairs(t) do
    if type(v) == "table" then
      msg = indentStr .. M.show_table(v or '', indent+1)
    else
      msg = indentStr ..  k .. " => " .. v
    end
    
    M.log_message(msg)
  end
end

function M.log_message(str)
  ngx.log(0, str)
end

function M.newline()
  ngx.log(0,"  ---   ")
end

function M.log(content)
  if type(content) == "table" then
    M.log_message(M.show_table(content))
  else
    M.log_message(content)
  end
  M.newline()
end

-- End Logging Helpers

-- Table Helpers
function M.keys(t)
  local n=0
  local keyset = {}
  for k,v in pairs(t) do
    n=n+1
    keyset[n]=k
  end
  return keyset
end
-- End Table Helpers


function M.dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then 
        k = '"'..k..'"' 
      end
      s = s .. '['..k..'] = ' .. M.dump(v) .. ','
    end
      return s .. '} '
  else
    return tostring(o)
  end
end

function M.sha1_digest(s)
  local str = require "resty.string"
  return str.to_hex(ngx.sha1_bin(s))
end

-- returns true iif all elems of f_req are among actual's keys
function M.required_params_present(f_req, actual)
  local req = {}
  for k,v in pairs(actual) do
    req[k] = true
  end
  for i,v in ipairs(f_req) do
    if not req[v] then
      return false
    end
  end
  return true
end

function M.connect_redis(red)
  local ok, err = red:connect("127.0.0.1", 6379)
  if not ok then
    ngx.say("failed to connect: ", err)
    ngx.exit(ngx.HTTP_OK)
  end
  return ok, err
end

-- error and exist
function M.error(text)
  ngx.say(text)
  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

function M.missing_args(text)
  ngx.say(text)
  ngx.exit(ngx.HTTP_OK)
end

return M

-- -- Example usage:
-- local MM = require 'mymodule'
-- MM.bar()