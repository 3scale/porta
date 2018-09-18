class Apicast::LuaAuthorizeGenerator < Apicast::LuaGenerator
  def filename
    'authorize.lua'.freeze
  end

  def emit(_)
    render template: 'lua_authorize'
  end
end
