# frozen_string_literal: true

require 'test_helper'

class ProxyRuleDecoratorTest < Draper::TestCase
  setup do
    @backend_api = FactoryBot.create(:backend_api)
  end

  attr_reader :backend_api, :service

  test 'pattern for backend with path' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/hello')
    decorator = proxy_rule.decorate(context: { backend_api_path: 'mybackend' })
    assert_equal '/mybackend/hello', decorator.pattern
  end

  test 'pattern for backend without path' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/hello')
    decorator = proxy_rule.decorate(context: { backend_api_path: '' })
    assert_equal '/hello', decorator.pattern
  end

  test 'catch-all pattern for backend with path' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/')
    decorator = proxy_rule.decorate(context: { backend_api_path: 'mybackend' })
    assert_equal '/mybackend', decorator.pattern
  end

  test 'catch-all pattern for backend without path' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/')
    decorator = proxy_rule.decorate(context: { backend_api_path: '' })
    assert_equal '/', decorator.pattern
  end
end
