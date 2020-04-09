# frozen_string_literal: true

require 'test_helper'

class LuaUtilityTest < ActiveSupport::TestCase
  test '#escape' do
    assert_equal 'mystring', LuaUtility.escape('mystring')
    assert_equal 'my%%string', LuaUtility.escape('my%string')
    assert_equal 'my%-string', LuaUtility.escape('my-string')
    assert_equal 'my%+string', LuaUtility.escape('my+string')
    assert_equal 'my%(string', LuaUtility.escape('my(string')
    assert_equal 'my%(string%)', LuaUtility.escape('my(string)')
    assert_equal 'my%*string', LuaUtility.escape('my*string')
    assert_equal 'my%[string]', LuaUtility.escape('my[string]')
    assert_equal 'my%^string', LuaUtility.escape('my^string')
    assert_equal 'my%$string', LuaUtility.escape('my$string')
    assert_equal 'my@string', LuaUtility.escape('my@string')
    assert_equal 'my%-c/o/o/l%-string', LuaUtility.escape('my-c/o/o/l-string')
  end
end
