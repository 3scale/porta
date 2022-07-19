# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Admin::Account::OgoneControllerTest < DeveloperPortal::DeprecatedPaymentGatewaysControllerTest

  test '#show' do
    ogone = mock
    ogone.expects(:url)
    ogone.expects(:fields).returns({})
    ogone.expects(:fill_fields).with "http://#{@provider.external_domain}/admin/account/ogone/hosted_success"

    PaymentGateways::OgoneCrypt.expects(:new).returns(ogone)
    get :show
    assert_response :success
  end

  test '#hosted_success' do
    PaymentGateways::OgoneCrypt.any_instance.expects(:success?).returns(true)

    get :hosted_success, params: { ED: '0718', CARDNO: 'XXXXXXXXXXXX1111' }

    @account.reload

    assert_equal '1111', @account.credit_card_partial_number
    assert_equal '2018-07-01', @account.credit_card_expires_on.to_s
    assert_redirected_to '/admin/account/ogone'
  end

  test '#hosted_success with plan changes' do
    PaymentGateways::OgoneCrypt.any_instance.expects(:success?).returns(true)
    session[:plan_changes] = {1 => 2}

    get :hosted_success, params: { ED: '0718', CARDNO: 'XXXXXXXXXXXX1111' }

    @account.reload

    assert_equal '1111', @account.credit_card_partial_number
    assert_equal '2018-07-01', @account.credit_card_expires_on.to_s
    assert_redirected_to admin_account_plan_changes_path
  end

  test '#hosted_success suspend account when failure count is higher than threshold' do
    PaymentGateways::OgoneCrypt.any_instance.expects(:success?).returns(false)
    ActionLimiter.any_instance.stubs(:perform!).raises(ActionLimiter::ActionLimitsExceededError)

    post :hosted_success

    @account.reload

    assert @account.suspended?
  end

  test '#hosted_success does not suspend account when failure count is below the threshold' do
    PaymentGateways::OgoneCrypt.any_instance.expects(:success?).returns(false)

    post :hosted_success

    @account.reload

    assert_not @account.suspended?
  end
end
