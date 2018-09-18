require 'test_helper'

class DeveloperPortal::Admin::Account::Adyen12ControllerTest < DeveloperPortal::AbstractPaymentGatewaysControllerTest
  include ActiveMerchantTestHelpers
  include ActiveMerchantTestHelpers::Adyen12

  test '#show' do
    get :show
    assert_response :success
  end

  test '#hosted_success without errors' do
    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')
    json = {
      'expiryMonth' => 02,
      'expiryYear' => 2017,
      'number' => 4444
    }
    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(successful_adyen_response)
    ::PaymentGateways::Adyen12Crypt.any_instance.expects(:retrieve_card_details).returns(json)

    get :hosted_success
    @account.reload

    assert_equal '2017-02-01', @account.credit_card_expires_on.to_s
    assert_equal '4444', @account.credit_card_partial_number
    assert_redirected_to '/admin/account/adyen12'
  end

  test '#hosted_success with errors in authorize' do
    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')

    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(failing_adyen_response)
    ::PaymentGateways::Adyen12Crypt.any_instance.expects(:retrieve_card_details).never

    get :hosted_success
    @account.reload

    assert_nil @account.credit_card_expires_on
    assert_nil @account.credit_card_partial_number
    assert_redirected_to '/admin/account/adyen12'
  end

  test '#hosted_success with errors in authorize with plan changes' do
    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')

    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(failing_adyen_response)
    ::PaymentGateways::Adyen12Crypt.any_instance.expects(:retrieve_card_details).never
    session[:plan_changes] = {1 => 2}

    get :hosted_success
    @account.reload

    assert_nil @account.credit_card_expires_on
    assert_nil @account.credit_card_partial_number
    assert_redirected_to '/admin/account/adyen12'
  end

  test '#hosted_success with plan changes' do
    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')
    json = {
      'expiryMonth' => 02,
      'expiryYear' => 2017,
      'number' => 4444
    }
    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(successful_adyen_response)
    ::PaymentGateways::Adyen12Crypt.any_instance.expects(:retrieve_card_details).returns(json)
    session[:plan_changes] = {1 => 2}

    get :hosted_success
    @account.reload

    assert_equal '2017-02-01', @account.credit_card_expires_on.to_s
    assert_equal '4444', @account.credit_card_partial_number
    assert_redirected_to admin_account_plan_changes_path
  end

  test '#hosted_success with unconfigured gateway' do
    setting = @provider.payment_gateway_setting
    setting.gateway_settings = setting.gateway_settings.except(:merchantAccount)
    setting.save!

    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')

    assert_nothing_raised ArgumentError do
      get :hosted_success
    end
  end

  test 'specific Adyen error message flashed when failed to store card' do
    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')

    params = {
      'refusalReason' => 'Some Refusal Reason',
      'resultCode' => 'Failed'
    }
    response = ActiveMerchant::Billing::Response.new(false, 'authorization failed', params)
    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(response)

    ::PaymentGateways::Adyen12Crypt.any_instance.expects(:store_credit_card_details).never

    Payment::Adyen12ErrorsHandler.stub_const(:ERROR_MESSAGES, { 'Some Refusal Reason' => 'Specific error message to flash' }) do
      get :hosted_success

      assert_redirected_to '/admin/account/adyen12'
      assert_equal "Specific error message to flash", flash[:error]
    end
  end

  test 'flashes default error message when gateway is not configured' do
    # We have created a profile in '#show' so credit_card_auth_code must be present
    @account.update_attribute(:credit_card_auth_code, 'authcode')

    Account.any_instance.stubs(:payment_gateway_configured?).returns(false)

    get :hosted_success

    assert_redirected_to '/'
    expected_message = DeveloperPortal::Admin::Account::Adyen12Controller.const_get(:DEFAULT_GATEWAY_ERROR_MESSAGE)
    assert_equal expected_message, flash[:error]
  end

  test '#hosted_success with alias present' do
    json = {
      'expiryMonth' => 02,
      'expiryYear' => 2017,
      'number' => 4444,
      'alias' => 'H123456789012345',
      'recurringDetailReference' => '8313147988756818'
    }
    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(successful_adyen_authorization_response_with_card_alias('H123456789012345'))
    ::PaymentGateways::Adyen12Crypt.any_instance.expects(:retrieve_card_details).returns(json)

    get :hosted_success
    @account.reload
    assert_equal '2017-02-01', @account.credit_card_expires_on.to_s
    assert_equal '4444', @account.credit_card_partial_number
    assert_equal '8313147988756818', @account.payment_detail.payment_service_reference
    assert_redirected_to '/admin/account/adyen12'
  end

  test '#hosted_success reusing previously used card with alias' do
    # card 1
    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(successful_adyen_authorization_response_with_card_alias('H123456789012345'))
    ::ActiveMerchant::Billing::Adyen12Gateway.any_instance.expects(:list_recurring_details).returns(successful_adyen_response)
    get :hosted_success
    @account.reload
    assert_equal '2017-02-01', @account.credit_card_expires_on.to_s
    assert_equal '0380', @account.credit_card_partial_number

    # card 2
    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(successful_adyen_authorization_response_with_card_alias('H167852639363479'))
    ::ActiveMerchant::Billing::Adyen12Gateway.any_instance.expects(:list_recurring_details).returns(successful_adyen_response_with_multiples_cards)
    get :hosted_success
    @account.reload
    assert_equal '2020-10-01', @account.credit_card_expires_on.to_s
    assert_equal '1111', @account.credit_card_partial_number

    # card 1 again
    ::PaymentGateways::Adyen12Crypt.any_instance.stubs(:authorize_with_encrypted_card).returns(successful_adyen_authorization_response_with_card_alias('H123456789012345'))
    ::ActiveMerchant::Billing::Adyen12Gateway.any_instance.expects(:list_recurring_details).returns(successful_adyen_response_with_multiples_cards)
    get :hosted_success
    @account.reload
    assert_equal '2017-02-01', @account.credit_card_expires_on.to_s
    assert_equal '0380', @account.credit_card_partial_number
  end
end
