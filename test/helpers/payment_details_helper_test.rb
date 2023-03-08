# frozen_string_literal: true

require 'test_helper'

class PaymentDetailsHelperTest < DeveloperPortal::ActionView::TestCase
  test '#credit_card_terms_url' do
    stubs(:site_account).returns(mock(settings: mock(cc_terms_path: '/terms')))
    assert_match '/terms', credit_card_terms_url
  end

  test '#credit_card_privacy_url' do
    stubs(:site_account).returns(mock(settings: mock(cc_privacy_path: '/privacy')))
    assert_match '/privacy', credit_card_privacy_url
  end

  test '#credit_card_refunds_url' do
    stubs(:site_account).returns(mock(settings: mock(cc_refunds_path: '/refunds')))
    assert_match '/refunds', credit_card_refunds_url
  end

  test '#link_to_payment_details' do
    stubs(:payment_details_path).returns('/payment-details')
    assert_match '/payment-details', link_to_payment_details('Payment Details')
  end

  test '#payment_details_path' do
    unacceptable_account = mock(unacceptable_payment_gateway?: true)
    assert_empty payment_details_path(unacceptable_account)

    account = mock(unacceptable_payment_gateway?: false, payment_gateway_type: :stripe)
    assert_equal '/admin/account/stripe?foo=bar&hello=world', payment_details_path(account, {foo: 'bar', hello: 'world'})
  end

  test '#merchant_countries' do
    assert_equal %w[Afghanistan AF], merchant_countries[0]
  end

  test '#payment_details_definition_list_item' do
    account = FactoryBot.build(:account, billing_address_first_name: '',
                                         billing_address_last_name: '',
                                         billing_address_address1: '',
                                         billing_address_city: '',
                                         billing_address_country: '',
                                         billing_address_name: '',
                                         billing_address_phone: '',
                                         billing_address_state: '',
                                         billing_address_zip: '')

    %w[first_name last_name phone zip city state country].each do |field|
      assert_nil payment_details_definition_list_item(field, account)
    end

    account = FactoryBot.build(:account, billing_address_first_name: 'first_name',
                                         billing_address_last_name: 'last_name',
                                         billing_address_address1: 'address1',
                                         billing_address_city: 'city',
                                         billing_address_country: 'Spain',
                                         billing_address_name: 'name',
                                         billing_address_phone: 'phone',
                                         billing_address_state: 'state',
                                         billing_address_zip: 'zip')

    %w[first_name last_name phone zip city state country].each do |field|
      assert_not_nil payment_details_definition_list_item(field, account)
    end
  end

  test '#stripe_form_data' do
    stubs(:current_account).returns(FactoryBot.create(:simple_account))
    stubs(:stripe_billing_address).returns({})
    stubs(:site_account).returns(mock(payment_gateway_options: { :publishable_key => 'publishable_key' }))
    stubs(:hosted_success_admin_account_stripe_path).returns('/ou-yeah')
    intent = mock(client_secret: 'super-secret')

    expected = {
      stripePublishableKey: 'publishable_key',
      setupIntentSecret: 'super-secret',
      billingAddress: {},
      successUrl: '/ou-yeah',
      creditCardStored: false
    }

    assert_equal expected, stripe_form_data(intent)
  end

  test '#stripe_billing_address' do
    account = FactoryBot.build(:account, billing_address_address1: 'address1',
                                         billing_address_address2: 'address2',
                                         billing_address_city: 'city',
                                         billing_address_state: 'state',
                                         billing_address_zip: 'zip',
                                         billing_address_country: 'ES')
    stubs(:current_account).returns(account)
    stubs(:logged_in?).returns(true).once

    expected_response = {
      line1: 'address1',
      line2: 'address2',
      city: 'city',
      state: 'state',
      postal_code: 'zip',
      country: 'ES'
    }
    assert_equal expected_response, stripe_billing_address
  end

  test '#braintree_form_data without billing address' do
    stubs(:current_account).returns(FactoryBot.build(:simple_account))
    stubs(:site_account).returns(mock(payment_gateway_options: { three_ds_enabled: true }))
    stubs(:merchant_countries).returns([])
    stubs(:braintree_authorization).returns('token')
    stubs(:billing_address).returns({})

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
    stubs(:country_code_for).with('country').returns('ES').once
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
      countryCode: 'ES',
      company: 'name',
      phone: 'phone',
      state: 'state',
      zip: 'zip'
    }
    assert_equal expected, billing_address_data
  end

  test '#country_code_for' do
    stubs(:merchant_countries).returns([%w[Spain ES]])

    assert_nil country_code_for('')
    assert_nil country_code_for(nil)

    assert_equal 'ES', country_code_for('Spain')
  end

  private

  def empty_billing_address_data
    %i[firstName lastName address city country countryCode company phone state zip].collect { |field| [field, ''] }.to_h
  end
end
