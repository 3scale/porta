# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::ContentSecurityPolicyTest < ActionDispatch::IntegrationTest

  class TestController < ApplicationController
    def html
      render html: '<html><body>Test</body></html>'.html_safe
    end

    def json
      render json: { test: true }
    end

    def not_modified
      head :not_modified
    end
  end

  def with_test_routes
    DeveloperPortal::Engine.routes.draw do
      get '/test/csp/html' => 'content_security_policy_test/test#html'
      get '/test/csp/json' => 'content_security_policy_test/test#json'
      get '/test/csp/304' => 'content_security_policy_test/test#not_modified'
    end
    yield
  ensure
    Rails.application.routes_reloader.reload!
  end

  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    host! @provider.internal_domain
  end

  test 'includes configured directives from YAML' do
    with_test_routes do
      get '/test/csp/html'

      assert_response :success
      csp_header = response.headers['Content-Security-Policy']

      # Verify it contains the permissive default_src directive from developer_portal_policy
      assert_includes csp_header, "default-src"
      assert_includes csp_header, "*"
      assert_includes csp_header, "'unsafe-eval'"
      assert_includes csp_header, "'unsafe-inline'"
    end
  end

  # See https://discuss.rubyonrails.org/t/cve-2024-28103-permissions-policy-is-only-served-on-html-content-type/85948
  test 'applies CSP headers to non-HTML responses' do
    with_test_routes do
      get '/test/csp/json', params: { format: :json }

      assert_response :success
      csp_header = response.headers['Content-Security-Policy']

      # Verify it contains the permissive default_src directive from developer_portal_policy
      assert_includes csp_header, "default-src"
      assert_includes csp_header, "*"
      assert_includes csp_header, "'unsafe-eval'"
      assert_includes csp_header, "'unsafe-inline'"
    end
  end

  test 'middleware handles 304 Not Modified responses correctly' do
    # The middleware has special handling for 304 responses to avoid
    # nonce mismatches with cached content. This test verifies the middleware
    # returns early for 304 responses and does not add CSP headers.

    with_test_routes do
      get '/test/csp/304'

      assert_response :not_modified
      # CSP middleware should not add headers to 304 responses
      assert_nil response.headers['Content-Security-Policy']
      assert_nil response.headers['Content-Security-Policy-Report-Only']
    end
  end
end
