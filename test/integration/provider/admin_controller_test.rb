# frozen_string_literal: true

require 'test_helper'

class Provider::AdminControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)

    login! provider
  end

  attr_reader :provider

  def test_show
    get provider_admin_path # without onboarding
    assert_redirected_to provider_admin_dashboard_path

    provider.create_onboarding

    get provider_admin_path # for the first time
    assert_redirected_to provider_admin_onboarding_wizard_root_path

    get provider_admin_path # for the second time
    assert_redirected_to provider_admin_dashboard_path

    get provider_admin_path # when all finished
    assert_redirected_to provider_admin_dashboard_path
  end

  test 'show should redirect to dashboard when user does not have permissions' do
    user = FactoryBot.create(:pending_user)
    provider.create_onboarding.start_wizard
    provider.users << user
    login!(provider, user: user)

    get provider_admin_path

    assert_redirected_to provider_admin_dashboard_path
  end
end
