# frozen_string_literal: true

require 'test_helper'

class PaymentDetailsHelperTest < DeveloperPortal::ActionView::TestCase
  test '#payment_details_path' do
    account = Account.new(payment_gateway_type: :stripe)
    assert_equal '/admin/account/stripe?foo=bar&hello=world', payment_details_path(account, {foo: 'bar', hello: 'world'})
  end

  test '#edit_payment_details_path' do
    account = Account.new(payment_gateway_type: :stripe)
    assert_equal "#{@request.scheme}://#{@request.host}/admin/account/stripe/edit", edit_payment_details(account)
  end

  test '#stripe_billing_address_json' do
    billing_address = current_account.billing_address
    expected_response = {
      line1: billing_address.address1,
      line2: billing_address.address2,
      city: billing_address.city,
      state: billing_address.state,
      postal_code: billing_address.zip,
      country: billing_address.country
    }.to_json
    assert_equal expected_response, stripe_billing_address_json

    stubs(current_account: nil)
    assert_nil stripe_billing_address_json
  end

  test '#braintree_form_data without billing address' do
    stubs(:site_account).returns(mock(payment_gateway_options: { three_ds_enabled: true }))
    stubs(:merchant_countries).returns([])
    stubs(:braintree_authorization).returns('token')
    stubs(:has_billing_address?).returns(false)

    expected = {
      formActionPath: '/admin/account/braintree_blue/hosted_success',
      threeDSecureEnabled: true,
      clientToken: 'token',
      countriesList: [],
      billingAddress: empty_billing_address_data
    }

    assert_equal expected, braintree_form_data
  end

  test '#braintree_address_data with billing address' do
    stubs(:site_account).returns(mock(payment_gateway_options: { three_ds_enabled: true }))
    stubs(:merchant_countries).returns([])
    stubs(:braintree_authorization).returns('token')
    stubs(:has_billing_address?).returns(true)

    account = FactoryBot.build(:account)
    stubs(:current_account).returns(account)

    expected = {
      formActionPath: '/admin/account/braintree_blue/hosted_success',
      threeDSecureEnabled: true,
      clientToken: 'token',
      countriesList: [],
      billingAddress: billing_address_data
    }

    assert_equal expected, braintree_form_data
  end

  test '#billing_address_data' do
    account = FactoryBot.build(:account, billing_address_first_name: 'first_name',
                                         billing_address_last_name: 'last_name',
                                         billing_address_address1: 'address1',
                                         billing_address_city: 'city',
                                         billing_address_country: 'country',
                                         billing_address_name: 'name',
                                         billing_address_phone: 'phone',
                                         billing_address_state: 'state',
                                         billing_address_zip: 'zip')
    stubs(:current_account).returns(account)
    expected = {
      firstName: 'first_name',
      lastName: 'last_name',
      address: 'address1',
      city: 'city',
      country: 'country',
      company: 'name',
      phone: 'phone',
      state: 'state',
      zip: 'zip'
    }

    assert_equal expected, billing_address_data
  end

  test '#empty_billing_address_data' do
    data = empty_billing_address_data
    %i[firstName lastName address city country company phone state zip].each do |key|
      assert_equal '', data[key]
    end
  end

  private

  def current_account
    FactoryBot.build(:simple_account)
  end

  def logged_in?
    !!current_account
  end
end
