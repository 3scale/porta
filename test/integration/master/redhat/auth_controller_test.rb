require 'test_helper'

class Master::Redhat::AuthControllerTest < ActionDispatch::IntegrationTest

  def setup
    @master = master_account
    @callback_url = "/auth/#{RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME}/callback"

    ThreeScale.config.redhat_customer_portal.stubs(enabled: true)
  end

  test 'master callback redirects to provider callback - auth code flow' do
    ThreeScale.config.redhat_customer_portal.stubs(:flow).returns('auth_code')
    host! @master.admin_domain
    get "#{@callback_url}?self_domain=example.com"
    assert_redirected_to "http://example.com/p/admin#{@callback_url}"
  end

  test 'master callback redirects to provider callback - implicit flow' do
    ThreeScale.config.redhat_customer_portal.stubs(:flow).returns('implicit')
    host! @master.admin_domain
    get "#{@callback_url}?self_domain=example.com"
    assert_response :success
    assert_match /(\<script).*(auth-redirect).*/, response.body
  end

  test 'Red Hat Customer Portal disabled' do
    ThreeScale.config.redhat_customer_portal.stubs(enabled: false)

    host! @master.admin_domain
    get "#{@callback_url}?self_domain=example.com"
    assert_equal 404, response.status
  end

  test 'unsupported flow' do
    ThreeScale.config.redhat_customer_portal.expects(flow: 'unsupported')
    host! @master.admin_domain
    assert_raise ThreeScale::OAuth2::ClientBase::UnsupportedFlowError do
      get "#{@callback_url}?self_domain=example.com"
    end
  end
end
