require 'test_helper'

class DeveloperPortal::Admin::Account::OgoneControllerTest < DeveloperPortal::DeprecatedPaymentGatewaysControllerTest

  test '#show' do
    ogone = mock
    ogone.expects(:url)
    ogone.expects(:fields).returns Hash.new
    ogone.expects(:fill_fields).with "http://#{@provider.domain}/admin/account/ogone/hosted_success"

    PaymentGateways::OgoneCrypt.expects(:new).returns(ogone)
    get :show
    assert_response :success
  end

  test '#hosted_success' do
    PaymentGateways::OgoneCrypt.any_instance.expects(:success?).returns(true)

    get :hosted_success, ED: '0718', CARDNO: 'XXXXXXXXXXXX1111'

    @account.reload

    assert_equal '1111', @account.credit_card_partial_number
    assert_equal '2018-07-01', @account.credit_card_expires_on.to_s
    assert_redirected_to '/admin/account/ogone'
  end

  test '#hosted_success with plan changes' do
    PaymentGateways::OgoneCrypt.any_instance.expects(:success?).returns(true)
    session[:plan_changes] = {1 => 2}

    get :hosted_success, ED: '0718', CARDNO: 'XXXXXXXXXXXX1111'

    @account.reload

    assert_equal '1111', @account.credit_card_partial_number
    assert_equal '2018-07-01', @account.credit_card_expires_on.to_s
    assert_redirected_to admin_account_plan_changes_path
  end
end
