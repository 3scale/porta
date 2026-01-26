# frozen_string_literal: true

require 'test_helper'

class ThreeScale::Middleware::DeveloperPortalPermissionsPolicyTest < ActiveSupport::TestCase

  test 'initializes with Permissions-Policy header when enabled with policy' do
    stub_permissions_policy_config(enabled: true, policy: default_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)

    assert_header_present middleware
    assert_header_value_includes middleware, "camera"
  end

  test 'initializes with no header when Permissions-Policy is disabled' do
    stub_permissions_policy_config(enabled: false, policy: default_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)

    assert_header_absent middleware
  end

  test 'initializes with no header when policy_config is nil' do
    stub_permissions_policy_config(enabled: true, policy: nil)

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)

    assert_header_absent middleware
  end

  test 'initializes with no header when policy_config is empty' do
    stub_permissions_policy_config(enabled: true, policy: {})

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)

    assert_header_absent middleware
  end

  test 'initializes with custom policy directives' do
    custom_policy = {
      camera: ["'self'"],
      microphone: ["'none'"],
      geolocation: ["'self'", 'https://example.com']
    }
    stub_permissions_policy_config(enabled: true, policy: custom_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)

    assert_header_present middleware
    assert_header_value_includes middleware, "camera 'self'"
    assert_header_value_includes middleware, "microphone 'none'"
    assert_header_value_includes middleware, "geolocation"
    assert_header_value_includes middleware, "https://example.com"
  end

  # Tests for #call method

  test 'call sets Feature-Policy header when policy is configured' do
    stub_permissions_policy_config(enabled: true, policy: default_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)
    env = mock_env
    _status, headers, _body = middleware.call(env)

    assert_not_nil headers['Feature-Policy']
    assert_includes headers['Feature-Policy'], "camera"
  end

  test 'call does not set Feature-Policy header when policy is empty' do
    stub_permissions_policy_config(enabled: true, policy: {})

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)
    env = mock_env
    _status, headers, _body = middleware.call(env)

    assert_nil headers['Feature-Policy']
  end

  test 'call does not set Feature-Policy header when policy is nil' do
    stub_permissions_policy_config(enabled: true, policy: nil)

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)
    env = mock_env
    _status, headers, _body = middleware.call(env)

    assert_nil headers['Feature-Policy']
  end

  test 'call does not set Feature-Policy header when disabled' do
    stub_permissions_policy_config(enabled: false, policy: default_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)
    env = mock_env
    _status, headers, _body = middleware.call(env)

    assert_nil headers['Feature-Policy']
  end

  test 'call clears permissions_policy on request when no header configured' do
    stub_permissions_policy_config(enabled: false, policy: default_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.new(mock_app)
    env = mock_env
    middleware.call(env)

    request = ActionDispatch::Request.new(env)
    assert_nil request.permissions_policy
  end

  private

  def mock_env
    Rack::MockRequest.env_for('http://example.com/test', 'HTTP_ACCEPT' => 'text/html')
  end

  def stub_permissions_policy_config(enabled:, policy:)
    ThreeScale::PermissionsPolicy::DeveloperPortal.stubs(:enabled?).returns(enabled)
    ThreeScale::PermissionsPolicy::DeveloperPortal.stubs(:policy_config).returns(policy)
  end

  def default_policy
    {
      camera: ["'none'"],
      microphone: ["'none'"],
      fullscreen: ["'self'"]
    }
  end

  def mock_app
    ->(env) { [200, {}, ['OK']] }
  end

  def assert_header_present(middleware)
    actual_value = middleware.instance_variable_get(:@permissions_policy_header_value)
    assert_not_nil actual_value, "Expected header to be present, but it was nil"
    assert actual_value.is_a?(String), "Expected header value to be a String, but got #{actual_value.class}"
    assert_not actual_value.empty?, "Expected header value to be non-empty"
  end

  def assert_header_absent(middleware)
    actual_value = middleware.instance_variable_get(:@permissions_policy_header_value)
    assert_nil actual_value, "Expected header to be absent, but got #{actual_value.inspect}"
  end

  def assert_header_value_includes(middleware, substring)
    actual_value = middleware.instance_variable_get(:@permissions_policy_header_value)
    assert_includes actual_value, substring, "Expected header value to include #{substring.inspect}"
  end
end
