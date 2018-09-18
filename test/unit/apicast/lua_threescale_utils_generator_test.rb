require 'test_helper'
require_relative 'lua_generator_test'

class Apicast::LuaThreescaleUtilsGeneratorTest < Apicast::LuaGeneratorTest
  def test_filename
    super
    assert_equal 'threescale_utils.lua', @generator.filename
  end

  def test_emit
    super
    assert config = @generator.emit(mock('provider'))
    assert_match '-- threescale_utils.lua', config
  end
end
