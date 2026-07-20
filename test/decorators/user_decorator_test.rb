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

  test 'accessible_services_with_token without plans permission' do
    provider = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:member, account: provider)
    FactoryBot.create(:service, account: provider)

    decorator = user.decorate

    assert_equal 0, decorator.accessible_services_with_token.count
  end

  test 'accessible_services_with_token returns services with tokens' do
    provider = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:member, :with_plans_permission, account: provider)

    service = FactoryBot.create(:service, account: provider)
    service.service_tokens.create!(value: 'token-value')

    decorator = user.decorate

    assert_equal 1, decorator.accessible_services_with_token.count
  end
end
