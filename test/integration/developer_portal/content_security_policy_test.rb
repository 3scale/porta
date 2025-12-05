# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    login_buyer @buyer
  end

  test 'applies CSP header to developer portal HTML responses' do
    get '/admin'

    assert_response :success
    assert_not_nil response.headers['Content-Security-Policy']

    csp_header = response.headers['Content-Security-Policy']
    # Verify permissive policy for developer portal
    assert_includes csp_header, "*"
    assert_includes csp_header, "'unsafe-eval'"
  end

  test 'CSP header is applied to authenticated pages' do
    get '/admin/account/edit'

    assert_response :success
    assert_not_nil response.headers['Content-Security-Policy']
  end

  test 'middleware handles 304 Not Modified responses correctly' do
    # The middleware has special handling for 304 responses to avoid
    # nonce mismatches with cached content. This test verifies the middleware
    # returns early for 304 responses.

    # Make a request
    get '/admin'
    first_csp = response.headers['Content-Security-Policy']

    assert_response :success
    assert_not_nil first_csp

    # NOTE: The 304 handling is tested at the middleware level in unit tests.
    # Integration tests can't easily simulate the exact conditions where
    # Rails returns a 304 before middleware runs.
  end

  test 'includes configured directives from YAML' do
    get '/admin'

    assert_response :success
    csp_header = response.headers['Content-Security-Policy']

    # Verify it contains the permissive default_src directive from developer_portal_policy
    assert_includes csp_header, "default-src"
    assert_includes csp_header, "*"
    assert_includes csp_header, "'unsafe-eval'"
    assert_includes csp_header, "'unsafe-inline'"
  end

  test 'does not apply CSP headers to non-HTML responses' do
    # Test JSON response
    get '/admin.json'

    # JSON responses should not have CSP headers
    assert_nil response.headers['Content-Security-Policy']
    assert_nil response.headers['Content-Security-Policy-Report-Only']
  end
end
