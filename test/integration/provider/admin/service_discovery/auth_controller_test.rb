# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::ServiceDiscovery::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @callback_url = "/p/admin/auth/#{ServiceDiscovery::AuthenticationProviderSupport::SERVICE_DISCOVERY_SYSTEM_NAME}/callback"

    ThreeScale.config.service_discovery.stubs(enabled: true, authentication_method: 'oauth')
    Rails.application.reload_routes!

    login_provider @provider
    host! @provider.external_admin_domain
  end

  test 'callback decodes referrer url' do
    user_data = ThreeScale::OAuth2::UserData.new(username: 'discovery_user')
    ServiceDiscovery::OAuthConfiguration.instance.stubs(
      token_endpoint: 'https://oauth.example.com/token',
      authorization_endpoint: 'https://oauth.example.com/authorize',
      userinfo_endpoint: 'https://oauth.example.com/userinfo'
    )
    ThreeScale::OAuth2::ServiceDiscoveryClient.any_instance.stubs(:authenticate!).returns(user_data)
    ThreeScale::OAuth2::ServiceDiscoveryClient.any_instance.stubs(:access_token).returns(stub(token: 'tok', expires_at: 1.hour.from_now.to_i))

    get @callback_url, params: { referrer: '/p/admin/dashboard%3Ffoo%3Dbar' }
    assert_redirected_to '/p/admin/dashboard?foo=bar'

    get @callback_url, params: { referrer: '/p/admin/search?q=hello+world' }
    assert_redirected_to '/p/admin/search?q=hello+world'

    get @callback_url, params: { referrer: '/p/admin/hello+world' }
    assert_redirected_to '/p/admin/hello+world'
  end
end
