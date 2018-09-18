class Apicast::LuaGetTokenGenerator < Apicast::LuaGenerator
  def filename
    'get_token.lua'.freeze
  end

  def emit(_)
    render template: 'lua_get_token'
  end
end
