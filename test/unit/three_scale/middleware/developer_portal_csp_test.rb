# frozen_string_literal: true

require 'test_helper'

class ThreeScale::Middleware::DeveloperPortalCSPTest < ActiveSupport::TestCase

  test 'initializes with CSP header when enabled with normal mode' do
    stub_csp_config(enabled: true, report_only: false, policy: default_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalCSP.new(mock_app)

    assert_header_name middleware, 'Content-Security-Policy'
    assert_header_value_present middleware
    assert_header_value_includes middleware, "default-src *"
  end

  test 'initializes with CSP report-only header when enabled with report-only mode' do
    stub_csp_config(enabled: true, report_only: true, policy: default_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalCSP.new(mock_app)

    assert_header_name middleware, 'Content-Security-Policy-Report-Only'
    assert_header_value_present middleware
    assert_header_value_includes middleware, "default-src *"
  end

  test 'initializes with permissive default policy when CSP is disabled' do
    stub_csp_config(enabled: false, report_only: false, policy: default_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalCSP.new(mock_app)

    assert_header_name middleware, 'Content-Security-Policy'
    assert_header_value_present middleware
    assert_header_value_includes middleware, "default-src *"
  end

  test 'initializes with permissive default policy when policy_config is nil' do
    stub_csp_config(enabled: true, report_only: false, policy: nil)

    middleware = ThreeScale::Middleware::DeveloperPortalCSP.new(mock_app)

    assert_header_name middleware, 'Content-Security-Policy'
    assert_header_value_present middleware
    assert_header_value_includes middleware, "default-src *"
  end

  test 'initializes with permissive default policy when policy_config is empty' do
    stub_csp_config(enabled: true, report_only: false, policy: {})

    middleware = ThreeScale::Middleware::DeveloperPortalCSP.new(mock_app)

    assert_header_name middleware, 'Content-Security-Policy'
    assert_header_value_present middleware
    assert_header_value_includes middleware, "default-src *"
  end

  test 'initializes with custom policy directives' do
    custom_policy = {
      default_src: ["'self'"],
      script_src: ["'self'", "'unsafe-inline'"],
      style_src: ["'self'", "https://cdn.example.com"]
    }
    stub_csp_config(enabled: true, report_only: false, policy: custom_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalCSP.new(mock_app)

    assert_header_name middleware, 'Content-Security-Policy'
    assert_header_value_includes middleware, "default-src 'self'"
    assert_header_value_includes middleware, "script-src 'self' 'unsafe-inline'"
    assert_header_value_includes middleware, "style-src 'self' https://cdn.example.com"
  end

  test 'initializes with permissive policy including data URIs and websockets' do
    permissive_policy = {
      default_src: ["*", "data:", "blob:", "ws:", "wss:", "'unsafe-eval'", "'unsafe-inline'"]
    }
    stub_csp_config(enabled: true, report_only: false, policy: permissive_policy)

    middleware = ThreeScale::Middleware::DeveloperPortalCSP.new(mock_app)

    assert_header_value_includes middleware, "default-src *"
    assert_header_value_includes middleware, "data:"
    assert_header_value_includes middleware, "blob:"
    assert_header_value_includes middleware, "ws:"
    assert_header_value_includes middleware, "wss:"
    assert_header_value_includes middleware, "'unsafe-eval'"
    assert_header_value_includes middleware, "'unsafe-inline'"
  end

  private

  def stub_csp_config(enabled:, report_only:, policy:)
    ThreeScale::ContentSecurityPolicy::DeveloperPortal.stubs(:enabled?).returns(enabled)
    ThreeScale::ContentSecurityPolicy::DeveloperPortal.stubs(:report_only?).returns(report_only)
    ThreeScale::ContentSecurityPolicy::DeveloperPortal.stubs(:policy_config).returns(policy)
  end

  def default_policy
    {
      default_src: ["*", "data:", "mediastream:", "blob:", "filesystem:", "ws:", "wss:", "'unsafe-eval'", "'unsafe-inline'"]
    }
  end

  def mock_app
    ->(env) { [200, {}, ['OK']] }
  end

  def assert_header_name(middleware, expected_name)
    actual_name = middleware.instance_variable_get(:@csp_header_name)
    if expected_name.nil?
      assert_nil actual_name, "Expected header name to be nil, but got #{actual_name.inspect}"
    else
      assert_equal expected_name, actual_name, "Expected header name to be #{expected_name.inspect}, but got #{actual_name.inspect}"
    end
  end

  def assert_header_value(middleware, expected_value)
    actual_value = middleware.instance_variable_get(:@csp_header_value)
    if expected_value.nil?
      assert_nil actual_value, "Expected header value to be nil, but got #{actual_value.inspect}"
    else
      assert_equal expected_value, actual_value, "Expected header value to be #{expected_value.inspect}, but got #{actual_value.inspect}"
    end
  end

  def assert_header_value_present(middleware)
    actual_value = middleware.instance_variable_get(:@csp_header_value)
    assert_not_nil actual_value, "Expected header value to be present, but it was nil"
    assert actual_value.is_a?(String), "Expected header value to be a String, but got #{actual_value.class}"
    assert_not actual_value.empty?, "Expected header value to be non-empty"
  end

  def assert_header_value_includes(middleware, substring)
    actual_value = middleware.instance_variable_get(:@csp_header_value)
    assert_includes actual_value, substring, "Expected header value to include #{substring.inspect}"
  end
end
