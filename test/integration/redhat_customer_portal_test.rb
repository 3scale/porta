require 'test_helper'

class RedhatCustomerPortalSupport::ControllerMethods::BannerTest < ActionDispatch::IntegrationTest
  test 'does not load oauth client when disabled' do
    ThreeScale.config.redhat_customer_portal.stubs(enabled: false)

    ThreeScale::OAuth2::RedhatCustomerPortalClient.expects(:new).never
    ThreeScale::OAuth2::RedhatCustomerPortalClient::ImplicitFlow.expects(:new).never

    login! master_account
    assert_response :success
  end

  test 'loads oauth client when enabled' do
    ThreeScale.config.redhat_customer_portal.stubs(enabled: true)
    ThreeScale.config.redhat_customer_portal.stubs(flow: 'implicit')

    authentication_provider = master_account.redhat_customer_authentication_provider
    authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)
    client = ThreeScale::OAuth2::RedhatCustomerPortalClient::ImplicitFlow.new(authentication)
    ThreeScale::OAuth2::Client.expects(:build).at_least_once.returns(client)

    login! master_account
    assert_response :success
  end
end