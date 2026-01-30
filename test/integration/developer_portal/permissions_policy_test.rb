# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::PermissionsPolicyTest < ActionDispatch::IntegrationTest

  class TestController < ApplicationController
    def html
      render html: '<html><body>Test</body></html>'.html_safe
    end
  end

  def with_test_routes
    DeveloperPortal::Engine.routes.draw do
      get '/test/permissions-policy/html' => 'permissions_policy_test/test#html'
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

  test 'includes Permissions-Policy header when developer portal policy is not empty' do
    policy_config = {
      camera: ["'none'"],
      microphone: ["'none'"],
      geolocation: ["'none'"]
    }
    policy = ThreeScale::PermissionsPolicy::DeveloperPortal.build_policy(policy_config)
    ThreeScale::Middleware::DeveloperPortalPermissionsPolicy.any_instance.stubs(permissions_policy_header_value: policy.build)

    with_test_routes do
      get '/test/permissions-policy/html'

      permissions_header = response.headers['Feature-Policy']

      # Verify it contains the permissive default_src directive from developer_portal_policy
      assert_includes permissions_header, "camera 'none'"
      assert_includes permissions_header, "microphone 'none'"
      assert_includes permissions_header, "geolocation 'none'"
    end
  end

  test 'does not include Permissions-Policy header when developer portal policy is empty' do
    # By default, developer portal has empty policy (permissive)
    with_test_routes do
      get '/test/permissions-policy/html'

      assert_response :success
      # Empty policy should not set any header
      assert_nil response.headers['Feature-Policy']
    end
  end
end
