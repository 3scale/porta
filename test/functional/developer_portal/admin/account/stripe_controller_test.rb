require 'test_helper'

class DeveloperPortal::Admin::Account::StripeControllerTest < DeveloperPortal::AbstractPaymentGatewaysControllerTest

  test '#show' do
    @account.billing_address = {
      address1: 'Carrer de Nàpols, 187',
      address2: 'Piso 8',
      city: 'Barcelona',
      state: 'Barcelona',
      zip: '08013',
      country: 'ES'
    }
    @account.save!

    get :show
    assert_response :success
    assert_select 'input[data-stripe="address_line1"][value="Carrer de Nàpols, 187"]'
    assert_select 'input[data-stripe="address_line2"][value="Piso 8"]'
    assert_select 'input[data-stripe="address_city"][value="Barcelona"]'
    assert_select 'input[data-stripe="address_state"][value="Barcelona"]'
    assert_select 'input[data-stripe="address_zip"][value="08013"]'
    assert_select 'input[data-stripe="address_country"][value="ES"]'
  end

  test '#hosted_success' do
    stripe_params = {
      stripe: { expires_on_month: '07', expires_on_year: '2018', partial_number: 'XXXXXXXXXXXX1111', token: 'token' },
      controller: @controller.controller_path,
      action: 'hosted_success'
    }.with_indifferent_access

    customer = mock do
      stubs(id: 'customer_id')
    end
    Stripe::Customer.expects(:create).returns(customer)
    get :hosted_success, stripe_params

    @account.reload

    assert_equal '2018-07-01', @account.credit_card_expires_on.to_s
    assert_equal 'customer_id', @account.credit_card_auth_code
    assert_equal '1111', @account.credit_card_partial_number

    assert_redirected_to '/admin/account/stripe'
  end

  test '#hosted_success with errors' do
    stripe_params = {
        stripe: { expires_on_month: '07', expires_on_year: '2018', partial_number: 'XXXXXXXXXXXX1111', token: 'token' },
        controller: @controller.controller_path,
        action: 'hosted_success'
    }.with_indifferent_access


    PaymentGateways::StripeCrypt.any_instance.expects(:update!).returns(false)
    get :hosted_success, stripe_params

    @account.reload

    assert_nil @account.credit_card_expires_on
    assert_nil @account.credit_card_auth_code
    assert_nil @account.credit_card_partial_number

    assert_redirected_to '/admin/account/stripe'
  end

  test '#hosted_success with plan changes' do
    stripe_params = {
      stripe: { expires_on_month: '07', expires_on_year: '2018', partial_number: 'XXXXXXXXXXXX1111', token: 'token' },
      controller: @controller.controller_path,
      action: 'hosted_success'
    }.with_indifferent_access

    customer = mock do
      stubs(id: 'customer_id')
    end
    Stripe::Customer.expects(:create).returns(customer)
    session[:plan_changes] = {1 => 2}

    get :hosted_success, stripe_params

    @account.reload

    assert_equal '2018-07-01', @account.credit_card_expires_on.to_s
    assert_equal 'customer_id', @account.credit_card_auth_code
    assert_equal '1111', @account.credit_card_partial_number
    assert_redirected_to admin_account_plan_changes_path
  end

  test '#hosted_success with errors with plan changes' do
    stripe_params = {
        stripe: { expires_on_month: '07', expires_on_year: '2018', partial_number: 'XXXXXXXXXXXX1111', token: 'token' },
        controller: @controller.controller_path,
        action: 'hosted_success'
    }.with_indifferent_access


    PaymentGateways::StripeCrypt.any_instance.expects(:update!).returns(false)
    session[:plan_changes] = {1 => 2}

    get :hosted_success, stripe_params

    @account.reload

    assert_nil @account.credit_card_expires_on
    assert_nil @account.credit_card_auth_code
    assert_nil @account.credit_card_partial_number

    assert_redirected_to '/admin/account/stripe'
  end
end
