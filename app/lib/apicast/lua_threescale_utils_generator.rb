class Apicast::LuaThreescaleUtilsGenerator < Apicast::LuaGenerator
  def filename
    'threescale_utils.lua'.freeze
  end

  def emit(_provider)
    render template: 'threescale_utils'
  end
end
