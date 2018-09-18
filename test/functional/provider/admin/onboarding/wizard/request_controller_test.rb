require 'test_helper'

class Provider::Admin::Onboarding::Wizard::RequestControllerTest < ActionController::TestCase

  def setup
    stub_request(:get, %r{http://test\.proxy/deploy}).to_return(status: 200)

    login_provider master_account
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_show
    get :show
    assert_response :success
  end

  def test_update
    stub_request(:get, %r{staging\.apicast\.dev}).to_return(status: 200, body: 'some body response')

    post :update, { request: { path: nil } }
    assert_redirected_to provider_admin_onboarding_wizard_request_path(response: 'some body response')

    post :update, { request: { path: '/path' } }
    assert_redirected_to provider_admin_onboarding_wizard_request_path(response: 'some body response')

    post :update, { request: { path: 'some invalid !!! path' } }
    assert_response :success

    # Not sure how to simulate this with new apicast (ApicastV2DeploymentService)
    
    #Logic::RollingUpdates.stubs(skipped?: true)
    #ProviderProxyDeploymentService.any_instance.stubs(deploy: false)

    #post :update, { request: { path: '/path' } }
    #assert_response :success
    #assert_match 'please try again', @response.body
  end
end
