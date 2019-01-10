require 'test_helper'

class Provider::Admin::Account::AuthenticationProviderFlowTestingTest < ActionDispatch::IntegrationTest

  def setup
    @account = FactoryBot.create(:provider_account)
    @auth_provider = FactoryBot.create(:self_authentication_provider, account: @account)
    @user = FactoryBot.create(:simple_user, account: @account)

    login_provider @account

    host! @account.admin_domain
  end

  def test_flow_testing
    get flow_testing_show_provider_admin_account_authentication_provider_path(@auth_provider)
    assert_response :redirect
  end

  def test_flow_testing_callback
    Authentication::Strategy::ProviderOauth2.any_instance.stubs(:authentication_provider).returns(@auth_provider)
    Authentication::Strategy::ProviderOauth2.any_instance.expects(:authenticate).returns(nil)
    get provider_admin_account_flow_testing_callback_url(system_name: @auth_provider.system_name)
    assert_nil flash[:success]

    Authentication::Strategy::ProviderOauth2.any_instance.expects(:authenticate).returns(@user)
    get provider_admin_account_flow_testing_callback_url(system_name: @auth_provider.system_name)
    assert_match 'Authentication flow successfully tested.', flash[:success]
  end

  def test_unsuccessful_callback
    Authentication::Strategy::ProviderOauth2.any_instance.stubs(:authentication_provider).returns(@auth_provider)
    Authentication::Strategy::ProviderOauth2.any_instance.stubs(:error_message).returns('some oauth error')
    Authentication::Strategy::ProviderOauth2.any_instance.expects(:authenticate).returns(false)
    get provider_admin_account_flow_testing_callback_url(system_name: @auth_provider.system_name)
    assert_match 'some oauth error', flash[:error]
  end
end
