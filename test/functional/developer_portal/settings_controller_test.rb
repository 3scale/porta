require 'test_helper'

class DeveloperPortal::SettingsControllerTest < DeveloperPortal::ActionController::TestCase

  setup do
    @provider = FactoryBot.create :provider_account
    request.host = @provider.domain
  end

  test 'get to terms should redirect' do

    get :terms
    assert_redirected_to root_path
  end

  test 'get to terms' do
    service= @provider.default_service
    service.update_attribute(:terms, "trolo")

    get :terms
    assert_response :success
  end

  test 'get to privacy should redirect' do

    get :privacy
    assert_redirected_to root_path
  end

  test 'get to privacy' do
    settings= @provider.settings
    settings.update_attribute(:privacy_policy, "trolo")

    get :privacy
    assert_response :success
  end

  test 'get to refund should redirect' do

    get :refunds
    assert_redirected_to root_path
  end

  test 'get to refund' do
    settings= @provider.settings
    settings.update_attribute(:refund_policy, "refund trolo")

    get :refunds
    assert_response :success
    assert_match "refund trolo", response.body
  end
end
