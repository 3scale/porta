# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Onboarding::Wizard::RequestControllerTest < ActionDispatch::IntegrationTest
  setup do
    provider = FactoryBot.create(:provider_account)
    FactoryBot.create(:service_token, service: provider.first_service!)
    host! provider.external_admin_domain
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
    assert_redirected_to provider_admin_onboarding_wizard_request_path(response: encode('some body response'))

    put provider_admin_onboarding_wizard_request_path(request: { path: '/path' })
    assert_redirected_to provider_admin_onboarding_wizard_request_path(response: encode('some body response'))

    put provider_admin_onboarding_wizard_request_path(request: { path: 'some invalid !!! path' })
    assert_response :success

    ProxyDeploymentService.any_instance.expects(call: false)
    put provider_admin_onboarding_wizard_request_path(request: { path: '/path' })
    assert_response :success
    assert_match 'please try again', response.body
  end

  test '#update truncates large api response before redirect' do
    very_long_api_response = 'some body response ' * 1000
    stub_request(:get, %r{staging\.apicast\.dev}).to_return(status: 200, body: very_long_api_response)

    truncated_response = very_long_api_response.slice(0...7669) + '…' # (1024*10-10)/(4/3) - 3 = 7669. Notice that -10 is due to reserved_bytes = provider_admin_onboarding_wizard_request_path(response: '').bytesize
    put provider_admin_onboarding_wizard_request_path(request: { path: nil })
    assert_redirected_to provider_admin_onboarding_wizard_request_path(response: encode(truncated_response))
  end

  test '#show decodes the response' do
    encoded_response = encode('some body response')
    get provider_admin_onboarding_wizard_request_path(response: encoded_response)
    assert_match /some body response/, response.body
  end

  protected

  def encode(content)
    Base64.urlsafe_encode64(content, padding: false)
  end
end
