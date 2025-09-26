# frozen_string_literal: true

require 'test_helper'

module DeveloperPortal
  class Admin::Account::StripeControllerTest < ActionDispatch::IntegrationTest
    include System::UrlHelpers.cms_url_helpers

    def setup
      secret_key = 'sk_test_fake_secret_key'
      publishable_key = 'pk_test_fake_publishable_key'
      @provider = FactoryBot.create(:provider_account, payment_gateway_type: :stripe, payment_gateway_options: {login: secret_key, publishable_key: publishable_key})
      provider.settings.allow_finance!
      provider.settings.show_finance!

      @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      login_buyer buyer
    end

    attr_reader :provider, :buyer

    test '#show' do
      client_secret = 'seti_fake_client_secret'
      setup_intent = Stripe::SetupIntent.new(id: 'seti_fake_setup_intent_id').tap { |si| si.update_attributes({ client_secret: client_secret }) }
      PaymentGateways::StripeCrypt.any_instance.expects(:create_stripe_setup_intent).returns(setup_intent)

      get admin_account_stripe_path

      assert_equal provider.payment_gateway_options.fetch(:publishable_key), assigns(:stripe_publishable_key)
      assert_equal setup_intent.id, assigns(:intent).id
      assert_equal setup_intent.client_secret, assigns(:intent).client_secret
    end

    test '#hosted_success' do
      payment_method_id = 'pm_fake_payment_method_id'

      PaymentGateways::StripeCrypt.any_instance.expects(:update_payment_detail).with(payment_method_id).returns(true)

      post hosted_success_admin_account_stripe_path, params: {stripe: {payment_method_id: payment_method_id}}

      assert_equal 'Credit card details were saved correctly', flash[:notice]
    end

    test '#update updates billing address successfully' do
      billing_address = {
        name: 'Some Name',
        address1: 'Some Address 1',
        address2: 'Some Address 2',
        city: 'Some City',
        country: 'US',
        state: 'Some State',
        zip: '123456'
      }.stringify_keys
      account_params = { account: { billing_address: billing_address } }

      PaymentGateways::StripeCrypt.any_instance.expects(:update_billing_address).with(billing_address).returns(true)

      put admin_account_stripe_path, params: account_params

      assert_redirected_to admin_account_stripe_url
      expected_address = ::Account::BillingAddress::Address.new(billing_address)
      assert_equal expected_address.to_s, buyer.reload.billing_address.to_s
    end

    test '#update shows an error if billing address is not updated on Stripe' do
      original_address = buyer.billing_address.to_s
      billing_address = {
        name: 'Some Name',
        address1: 'Some Address 1',
        address2: 'Some Address 2',
        city: 'Some City',
        country: 'US',
        state: 'Some State',
        zip: '123456'
      }
      account_params = { account: { billing_address: billing_address } }

      PaymentGateways::StripeCrypt.any_instance.expects(:update_billing_address).with(billing_address.stringify_keys).returns(false).at_least_once

      put admin_account_stripe_path, params: account_params

      assert_match 'Failed to update your billing address data. Check the required fields', flash[:error]
      assert_template 'accounts/payment_gateways/edit'
      assert_equal original_address, buyer.reload.billing_address.to_s
    end

    test '#update shows an error if billing address is not updated on account model' do
      original_address = buyer.billing_address.to_s
      billing_address = {
        address1: "A" * 256
      }
      account_params = { account: { billing_address: billing_address } }

      PaymentGateways::StripeCrypt.any_instance.expects(:update_billing_address).with(billing_address.stringify_keys).never

      put admin_account_stripe_path, params: account_params

      assert_match 'Failed to update your billing address data. Check the required fields', flash[:error]
      assert_template 'accounts/payment_gateways/edit'
      assert_equal original_address, buyer.reload.billing_address.to_s
    end
  end
end
