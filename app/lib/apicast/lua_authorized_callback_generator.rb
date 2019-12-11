class Apicast::LuaAuthorizedCallbackGenerator < Apicast::LuaGenerator
  def filename
    'authorized_callback.lua'.freeze
  end

  def emit(_)
    render template: 'lua_authorized_callback'
  end
end
