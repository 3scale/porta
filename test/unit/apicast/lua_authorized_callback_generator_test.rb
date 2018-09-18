require 'test_helper'
require_relative 'lua_generator_test'

class Apicast::LuaAuthorizedCallbackGeneratorTest < Apicast::LuaGeneratorTest
  def test_filename
    super
    assert_equal 'authorized_callback.lua', @generator.filename
  end

  def test_emit
    super
    assert config = @generator.emit(mock('provider'))
    assert_match '-- authorized_callback.lua', config
  end
end
