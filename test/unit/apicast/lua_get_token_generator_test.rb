require 'test_helper'
require_relative 'lua_generator_test'

class Apicast::LuaGetTokenGeneratorTest < Apicast::LuaGeneratorTest
  def test_filename
    super
    assert_equal 'get_token.lua', @generator.filename
  end

  def test_emit
    super
    assert config = @generator.emit(mock('provider'))
    assert_match 'function get_token()', config
  end
end
