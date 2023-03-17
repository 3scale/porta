# frozen_string_literal: true

require 'test_helper'

class ThreeScale::Middleware::CorsTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  setup do
    provider = FactoryBot.create(:simple_provider)
    @provider_domain = provider.internal_admin_domain
    @app = ->(env) { [403, {}, []] }
  end

  attr_reader :provider_domain, :app

  test 'allowed origin and resource' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: '*'}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 200, status
    assert headers['Access-Control-Allow-Origin']

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
    assert headers['Access-Control-Allow-Origin']
  end

  test 'disallowed origin' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: 'http://ui.other', resources: '/foo/*'}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 200, status
    assert_not headers['Access-Control-Allow-Origin']

    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
    assert_not headers['Access-Control-Allow-Origin']
  end

  test 'disallowed resource' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: '/foo/*'}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 200, status
    assert_not headers['Access-Control-Allow-Origin']

    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
    assert_not headers['Access-Control-Allow-Origin']
  end

  test 'disallowed method' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: '*'}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'PUT'))
    assert_equal 200, status
    assert_not headers['Access-Control-Allow-Origin']
  end

  test 'regexp resource' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: /\.json$/}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 200, status
    assert headers['Access-Control-Allow-Origin']

    status, headers, = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET', 'PATH_INFO' => "/non-json"))
    assert_equal 200, status
    assert_not headers['Access-Control-Allow-Origin']
  end

  test 'provider signup path excluded in example configs' do
    ["config/examples"].each do |config_dir|
      stub_config = YAML.load_file(Rails.root.join(config_dir, "cors.yml"))["cors"].merge({"enabled" => true})
      assert_not_empty stub_config["exclude"]

      Rails.configuration.three_scale.cors.stubs(stub_config)

      middleware = ThreeScale::Middleware::Cors.new(app)
      status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET', 'PATH_INFO' => provider_signup_path))
      assert_equal 403, status
      assert_not headers['Access-Control-Allow-Origin']
    end
  end

  test 'exclude path prefix with slash' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: '*'}], exclude: [{path_prefix: "/admin/api/"}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
    assert_not headers['Access-Control-Allow-Origin']

    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET', 'PATH_INFO' => "/admin/api"))
    assert_equal 200, status
    assert headers['Access-Control-Allow-Origin']
  end

  test 'exclude path prefix without slash' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: '*'}], exclude: [{path_prefix: "/admin/api"}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET', 'PATH_INFO' => "/admin/api"))
    assert_equal 403, status
    assert_not headers['Access-Control-Allow-Origin']

    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET', 'PATH_INFO' => "/admin/apixx"))
    assert_equal 200, status
    assert headers['Access-Control-Allow-Origin']

    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET', 'PATH_INFO' => "/p/admin/api"))
    assert_equal 200, status
    assert headers['Access-Control-Allow-Origin']
  end

  test 'exclude path prefix with regexp' do
    Rails.configuration.three_scale.cors.stubs(enabled: true, allow: [{origins: '*', resources: '*'}], exclude: [{path_regexp: "^/admin/api"}])

    middleware = ThreeScale::Middleware::Cors.new(app)
    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'))
    assert_equal 403, status
    assert_not headers['Access-Control-Allow-Origin']

    status, headers = middleware.call(env.merge('REQUEST_METHOD' => 'OPTIONS', 'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET', 'PATH_INFO' => "/provider"))
    assert_equal 200, status
    assert headers['Access-Control-Allow-Origin']
  end

  protected

  def env
    { 'HTTP_HOST' => provider_domain, 'PATH_INFO' => '/admin/api/services.json', 'HTTP_ORIGIN' => 'http://my.ui' }
  end
end
