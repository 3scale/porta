# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Onboarding::Wizard::RequestControllerTest < ActionDispatch::IntegrationTest
  setup do
    provider = FactoryBot.create(:provider_account)
    FactoryBot.create(:service_token, service: provider.first_service!)
    host! provider.self_domain
    login_provider provider
  end

  test 'new' do
    get new_provider_admin_onboarding_wizard_request_path
    assert_response :success
  end

  test 'show' do
    get provider_admin_onboarding_wizard_request_path
    assert_response :success
  end

  test 'update' do
    stub_request(:get, %r{staging\.apicast\.dev}).to_return(status: 200, body: 'some body response')

    put provider_admin_onboarding_wizard_request_path(request: { path: nil })
    assert_redirected_to provider_admin_onboarding_wizard_request_path(response: 'some body response')

    put provider_admin_onboarding_wizard_request_path(request: { path: '/path' })
    assert_redirected_to provider_admin_onboarding_wizard_request_path(response: 'some body response')

    put provider_admin_onboarding_wizard_request_path(request: { path: 'some invalid !!! path' })
    assert_response :success

    ProxyDeploymentService.any_instance.expects(call: false)
    put provider_admin_onboarding_wizard_request_path(request: { path: '/path' })
    assert_response :success
    assert_match 'please try again', response.body
  end
end
