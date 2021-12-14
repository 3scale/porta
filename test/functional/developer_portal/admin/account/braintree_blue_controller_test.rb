# frozen_string_literal: true

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

    post :hosted_success, params: form_params

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
    post :hosted_success, params: form_params

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

    post :hosted_success, params: form_params

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

    post :hosted_success, params: form_params

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

    post :hosted_success, params: form_params

    @account.reload

    assert_nil @account.credit_card_partial_number
    assert_nil @account.credit_card_expires_on
    assert_redirected_to action: 'edit', errors: failed_result.errors.map(&:message)
  end

  test '#hosted_success suspend account when failure count is higher than threshold' do
    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:confirm).returns(failed_result)
    ActionLimiter.any_instance.stubs(:perform!).raises(ActionLimiter::ActionLimitsExceededError)

    post :hosted_success, params: form_params

    @account.reload

    assert @account.suspended?
  end

  test '#hosted_success does not suspend account when failure count is below the threshold' do
    PaymentGateways::BrainTreeBlueCrypt.any_instance.expects(:confirm).returns(failed_result)

    post :hosted_success, params: form_params

    @account.reload

    assert_not @account.suspended?
  end

  protected

  def successful_result(user = nil)
    super(user || @buyer.admins.first)
  end

  def form_params
    {
      customer: {
        first_name: 'John',
        last_name: 'Doe',
        phone: '123456789',
        credit_card: {
          billing_address: {
            company: 'Invisible Inc.',
            street_address: '123 Main Street',
            postal_code: '12345',
            locality: 'Anytown',
            region: 'Nowhere',
            country_name: 'US'
          }
        }
      },
      braintree: {
        nonce: 'a_nonce',
        last_four: '7654'
      }
    }
  end
end
