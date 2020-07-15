# frozen_string_literal: true

require 'test_helper'

class UserDecoratorTest < Draper::TestCase
  def setup
    @user = FactoryBot.build(:admin)
    @decorator = user.decorate
  end

  attr_reader :user, :decorator

  test 'full_name' do
    user.first_name = 'Foo'
    user.last_name = 'Bar'
    assert_equal 'Foo Bar', decorator.full_name

    user.first_name = ' '
    user.last_name = 'Bar'
    assert_equal 'Bar', decorator.full_name

    user.first_name = 'Foo'
    user.last_name = ' '
    assert_equal 'Foo', decorator.full_name
  end

  test 'display_name' do
    user.first_name = 'Foo'
    user.last_name = 'Bar'
    user.username = 'Baz'
    assert_equal 'Foo Bar', decorator.display_name

    user.first_name = ' '
    user.last_name = ' '
    user.username = 'Baz'
    assert_equal 'Baz', decorator.display_name
  end

  test 'informal_name' do
    user.first_name = 'Foo'
    user.last_name = 'Bar'
    user.username = 'Baz'
    assert_equal 'Foo', decorator.informal_name

    user.first_name = ' '
    user.last_name = 'Bar'
    user.username = 'Baz'
    assert_equal 'Bar', decorator.informal_name

    user.first_name = ' '
    user.last_name = ' '
    user.username = 'Baz'
    assert_equal 'Baz', decorator.informal_name
  end
end
