# frozen_string_literal: true

require 'test_helper'

class Provider::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    host! @provider.admin_domain
    @authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider)
  end

  attr_reader :authentication_provider

  test 'bounce redirects to the authorize_url' do
    get authorization_provider_bounce_path(authentication_provider.system_name)
    request = ActionDispatch::TestRequest.create
    assert_redirected_to ProviderOauthFlowPresenter.new(authentication_provider, request, @provider.admin_domain).authorize_url
  end

  test 'bounce returns not found if the authentication provider belongs to another provider' do
    authentication_provider = FactoryBot.create(:self_authentication_provider)
    get authorization_provider_bounce_path(authentication_provider.system_name)
    assert_response :not_found
  end

  test 'bounce to an non-existent system_name' do
    get authorization_provider_bounce_path('fake-system-name')
    assert_response :not_found
  end

  test 'logout of provider with partner and logout_url' do
    partner = FactoryBot.create(:partner, logout_url: "http://example.net/?")
    account = FactoryBot.create(:provider_account, partner: partner)
    login! account

    delete provider_sessions_path

    assert_redirected_to "http://example.net/?provider_id=#{account.id}&user_id=#{account.admin_user.id}"
  end
end
