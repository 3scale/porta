require 'test_helper'
require_relative 'lua_generator_test'

class Apicast::LuaAuthorizeGeneratorTest < Apicast::LuaGeneratorTest
  def test_filename
    super
    assert_equal 'authorize.lua', @generator.filename
  end

  def test_emit
    super
    assert config = @generator.emit(mock('provider'))
    assert_match 'function authorize(params)', config
  end
end
