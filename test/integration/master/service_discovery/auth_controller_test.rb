# frozen_string_literal: true

require 'test_helper'

class Master::ServiceDiscovery::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:simple_provider)
    ThreeScale.config.service_discovery.stubs(enabled: true, authentication_method: 'oauth')
    Rails.application.reload_routes!
    host! master_account.internal_admin_domain
  end

  attr_reader :provider

  test 'master callback redirects to provider callback' do
    provider_self_domain = provider.external_admin_domain
    params = { code: '123', referrer: '/apiconfig/services/new', state: '' }
    get auth_service_discovery_callback_path(self_domain: provider_self_domain, **params)
    assert_redirected_to url_for(host: provider_self_domain, controller: 'provider/admin/service_discovery/auth', action: :show, **params)
  end
end
