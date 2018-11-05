# frozen_string_literal: true

require 'test_helper'

class Provider::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryGirl.create(:provider_account)
    host! @provider.admin_domain
    @authentication_provider = FactoryGirl.create(:self_authentication_provider, account: @provider)
  end

  attr_reader :authentication_provider

  test 'bounce redirects to the authorize_url' do
    get authorization_provider_bounce_path(authentication_provider.system_name)
    request = mock('request', scheme: 'http', query_parameters: {})
    assert_redirected_to ProviderOauthFlowPresenter.new(authentication_provider, request, @provider.admin_domain).authorize_url
  end

  test 'bounce returns not found if the authentication provider belongs to another provider' do
    authentication_provider = FactoryGirl.create(:self_authentication_provider)
    get authorization_provider_bounce_path(authentication_provider.system_name)
    assert_response :not_found
  end

  test 'bounce to an non-existent system_name' do
    get authorization_provider_bounce_path('fake-system-name')
    assert_response :not_found
  end
end
