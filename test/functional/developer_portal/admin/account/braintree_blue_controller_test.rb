require 'test_helper'

class DeveloperPortal::Admin::Account::BraintreeBlueControllerTest < DeveloperPortal::AbstractPaymentGatewaysControllerTest

  include ActiveMerchantTestHelpers::BraintreeBlue

  test '#show' do
    get :show
    assert_response :success
  end

  test '#hosted_success unstoring credit_card_auth_code' do

    # Account have a credit card auth code
    @account.update_attribute :credit_card_auth_code, 'authcode'

    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:confirm).returns(successful_result)

    @controller.stubs(current_account: @account)

    get :hosted_success

    @account.reload

    assert_equal '7654', @account.credit_card_partial_number
    assert_equal '2019-01-01', @account.credit_card_expires_on_with_default.to_s

    assert_redirected_to '/admin/account/braintree_blue'
  end

  test '#hosted_success' do
    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:confirm).returns(successful_result)

    # Account does not have a credit card auth code
    assert_nil @account.credit_card_auth_code

    @controller.stubs(current_account: @account)

    get :hosted_success

    @account.reload

    assert_equal '7654', @account.credit_card_partial_number
    assert_equal '2019-01-01', @account.credit_card_expires_on.to_s
    assert_redirected_to '/admin/account/braintree_blue'
  end

  test '#hosted_success with plan changes' do
    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:confirm).returns(successful_result)

    # Account does not have a credit card auth code
    assert_nil @account.credit_card_auth_code

    @controller.stubs(current_account: @account)
    session[:plan_changes] = {1 => 2}

    get :hosted_success

    @account.reload

    assert_equal '7654', @account.credit_card_partial_number
    assert_equal '2019-01-01', @account.credit_card_expires_on.to_s
    assert_redirected_to admin_account_plan_changes_path
  end

  test '#hosted_success with errors not storing credit card' do
    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:confirm).returns(successful_result)
    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:update_user).returns(false)

    # Account does not have a credit card auth code
    assert_nil @account.credit_card_auth_code

    @controller.stubs(current_account: @account)
    session[:plan_changes] = {1 => 2}

    get :hosted_success

    @account.reload

    assert_nil @account.credit_card_partial_number
    assert_nil @account.credit_card_expires_on
    assert_template 'accounts/payment_gateways/edit'
  end

  test '#hosted_success with errors' do
    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:confirm).returns(failed_result)
    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:update_user).never

    # Account does not have a credit card auth code
    assert_nil @account.credit_card_auth_code

    @controller.stubs(current_account: @account)
    session[:plan_changes] = {1 => 2}

    get :hosted_success

    @account.reload

    assert_nil @account.credit_card_partial_number
    assert_nil @account.credit_card_expires_on
    assert_redirected_to action: 'edit', errors: failed_result.errors.map(&:message)
  end

  protected

  def successful_result(user = nil)
    super(user || @buyer.admins.first)
  end
end
