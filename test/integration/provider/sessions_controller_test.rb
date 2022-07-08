# frozen_string_literal: true

require 'test_helper'

class Provider::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    host! @provider.external_admin_domain
    @authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider, published: true)
  end

  attr_reader :authentication_provider

  test 'bounce redirects to the authorize_url' do
    get authorization_provider_bounce_path(authentication_provider.system_name)
    request = ActionDispatch::TestRequest.create
    assert_redirected_to ProviderOauthFlowPresenter.new(authentication_provider, request, @provider.external_admin_domain).authorize_url
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

  test "redirect users to SSO when there's only one authentication provider and enforce_sso is on" do
    @provider.settings.update_column(:enforce_sso, true)
    get new_provider_sessions_path
    assert_redirected_to authorization_provider_bounce_path(authentication_provider.system_name)
  end

  test "redirect users to SSO when there's more than one authentication provider but only one is published " do
    @provider.settings.update_column(:enforce_sso, true)
    FactoryBot.create(:self_authentication_provider, account: @provider)
    get new_provider_sessions_path
    assert_redirected_to authorization_provider_bounce_path(authentication_provider.system_name)
  end

  test "does not redirect when there's more than one authentication provider" do
    @provider.settings.update_column(:enforce_sso, true)
    FactoryBot.create(:self_authentication_provider, account: @provider, published: true)
    get new_provider_sessions_path
    assert_response :success

    # password login is disabled, there's no passoword login form
    refute_match 'Email or Username', response.body
  end
end
