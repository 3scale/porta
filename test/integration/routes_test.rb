require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest

  def setup # delete existing master, as it can be corrupted from other tests
    master_account.users.delete_all
    master_account.send :destroy_features
    master_account.services.delete_all
    master_account.delete
  end

  def test_sidekiq
    login_provider FactoryGirl.create(:provider_account)
    assert_raise(ActionController::RoutingError) { get '/sidekiq' }

    login_provider master_account
    get '/sidekiq'
    assert_response :ok
    assert_match '<title>[TEST] Sidekiq', @response.body
  end

  def test_onboarding_redirect
    provider = FactoryGirl.create(:provider_account)
    provider.create_onboarding

    host! provider.admin_domain
    login_provider provider

    get '/p/admin'

    assert_redirected_to provider_admin_dashboard_path

  end

end
