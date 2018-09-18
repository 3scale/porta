require 'test_helper'

class TimedValueTest < ActiveSupport::TestCase

  test 'sets a var' do
    ThreeScale::TimedValue.set('foo', 'bar', 5)
    assert_equal 'bar', ThreeScale::TimedValue.get('foo')
  end

end
