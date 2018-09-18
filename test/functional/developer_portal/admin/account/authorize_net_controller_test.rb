require 'test_helper'

class DeveloperPortal::Admin::Account::AuthorizeNetControllerTest < DeveloperPortal::DeprecatedPaymentGatewaysControllerTest
  include ActiveMerchantTestHelpers
  include ActiveMerchantTestHelpers::AuthorizeNet

  test '#show' do
    credit_card_auth_code = states('credit_card_auth_code').starts_as('empty')
    @controller.stubs(:current_account).returns(@account)
    @account.stubs(credit_card_auth_code: nil).when(credit_card_auth_code.is('empty'))
    @account.stubs(credit_card_auth_code: 'authcode').when(credit_card_auth_code.is('filled'))
    authorize_net = mock
    authorize_net.expects(:create_profile).then(credit_card_auth_code.is('filled'))
    authorize_net.expects(:get_token).with(
      login:      'LoginID',
      trans_key:  'Transaction Key',
      profile_id: 'authcode',
      ok_url: "http://#{@provider.domain}/admin/account/authorize_net/hosted_success"
    )
    authorize_net.expects(:payment_profile)
    authorize_net.expects(:action_form_url)
    PaymentGateways::AuthorizeNetCimCrypt.expects(:new).returns(authorize_net)
    get :show
    assert_response :success
  end

  test '#hosted_success' do
    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')
    auth_response = successful_get_customer_profile_response
    ActiveMerchant::Billing::AuthorizeNetCimGateway.any_instance.stubs(:get_customer_profile).returns(auth_response)
    PaymentGateways::AuthorizeNetCimCrypt.any_instance.expects(:update_user).with(auth_response)

    get :hosted_success
    assert_redirected_to '/admin/account/authorize_net'
  end

  test '#hosted_success with plan changes' do
    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')
    auth_response = successful_get_customer_profile_response
    ActiveMerchant::Billing::AuthorizeNetCimGateway.any_instance.stubs(:get_customer_profile).returns(auth_response)
    PaymentGateways::AuthorizeNetCimCrypt.any_instance.expects(:update_user).with(auth_response)
    session[:plan_changes] = {1 => 2}

    get :hosted_success
    assert_redirected_to admin_account_plan_changes_path
  end
end
