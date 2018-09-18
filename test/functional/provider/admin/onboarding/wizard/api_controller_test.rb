require 'test_helper'

class Provider::Admin::Onboarding::Wizard::ApiControllerTest < ActionController::TestCase

  def setup
    login_provider master_account
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_update
    post :update, { api: { name: nil, endpoint: nil } }
    assert_response :success

    post :update, { api: { name: 'some name', backend: 'http://example.com' } }
    assert_redirected_to new_provider_admin_onboarding_wizard_request_path
  end
end
