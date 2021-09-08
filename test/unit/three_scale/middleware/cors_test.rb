# frozen_string_literal: true

require 'test_helper'

class ThreeScale::Middleware::CorsTest < ActiveSupport::TestCase
  setup do
    provider = FactoryBot.create(:simple_provider)
    @provider_domain = provider.external_self_domain
    @app = ->(env) { [403, {}, []] }
  end

  attr_reader :provider_domain, :app

  test 'cors disabled' do
    Rails.configuration.three_scale.cors.stubs(enabled: false)

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
  end

  test 'allowed origin and resource' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: '*'}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 200, status

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
    assert headers['Access-Control-Allow-Origin']
  end

  test 'disallowed origin' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: 'http://ui.other', resources: '/foo/*'}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 200, status

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
    refute headers['Access-Control-Allow-Origin']
  end

  test 'disallowed resource' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: '/foo/*'}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 200, status

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
    refute headers['Access-Control-Allow-Origin']
  end

  test 'regexp resource' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: /\.json$/}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 200, status
    assert headers['Access-Control-Allow-Origin']
  end

  protected

  def env
    { 'HTTP_HOST' => provider_domain, 'PATH_INFO' => '/admin/api/services.json', 'HTTP_ORIGIN' => 'http://my.ui' }
  end
end
