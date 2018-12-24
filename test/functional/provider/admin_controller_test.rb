require 'test_helper'

class Provider::AdminControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.admin_domain
    login_provider @provider
  end

  def test_show
    get :show # without onboarding
    assert_redirected_to provider_admin_dashboard_path

    @provider.create_onboarding

    get :show # for the first time
    assert_redirected_to provider_admin_onboarding_wizard_root_path

    get :show # for the second time
    assert_redirected_to provider_admin_dashboard_path

    @provider.onboarding.finish_process!

    get :show # when all finished
    assert_redirected_to provider_admin_dashboard_path
  end

  test 'show should redirect to dashboard when user does not have permissions' do
    user = FactoryBot.create(:pending_user)
    @provider.create_onboarding.start_wizard
    @provider.users << user
    login_as user

    get :show

    assert_redirected_to provider_admin_dashboard_path
  end

end
