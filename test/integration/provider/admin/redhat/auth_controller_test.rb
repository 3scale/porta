require 'test_helper'

class Provider::Admin::Redhat::AuthControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @callback_url = "/p/admin/auth/#{RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME}/callback"

    ThreeScale.config.redhat_customer_portal.stubs(enabled: true)
  end

  test 'successful provider callback - auth code flow' do
    ThreeScale.config.redhat_customer_portal.stubs(:flow).returns('auth_code')
    login_provider @provider
    host! @provider.admin_domain
    user_data = ThreeScale::OAuth2::UserData.new(username: 'redhat_user')
    ThreeScale::OAuth2::KeycloakClient.any_instance.stubs(:authenticate!).returns(user_data)
    get @callback_url
    assert_equal 'The Red Hat Login was linked to the account', flash[:notice]
  end

  test 'successful provider callback - implicit flow' do
    ThreeScale.config.redhat_customer_portal.stubs(:flow).returns('implicit')
    login_provider @provider
    host! @provider.admin_domain
    user_data = ThreeScale::OAuth2::UserData.new(username: 'redhat_user')
    ThreeScale::OAuth2::RedhatCustomerPortalClient::ImplicitFlow.any_instance.stubs(:authenticate!).returns(user_data)
    get @callback_url
    assert_equal 'The Red Hat Login was linked to the account', flash[:notice]
  end

  test 'undefined error on provider callback' do
    login_provider @provider
    host! @provider.admin_domain
    ThreeScale::OAuth2::KeycloakClient.any_instance.stubs(:authenticate!).returns(nil)
    assert_raise ThreeScale::OAuth2::ClientBase::ClientError do
      get @callback_url
    end
  end

  test 'Red Hat Customer Portal disabled' do
    ThreeScale.config.redhat_customer_portal.stubs(enabled: false)

    login_provider @provider
    host! @provider.admin_domain
    get @callback_url
    assert_equal 404, response.status
  end
end
