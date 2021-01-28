# frozen_string_literal: true

require 'test_helper'

module DeveloperPortal
  class Admin::Account::StripeControllerTest < ActionDispatch::IntegrationTest
    include System::UrlHelpers.cms_url_helpers
    include PaymentDetailsHelper

    def setup
      @provider = FactoryBot.create(:provider_account, payment_gateway_type: :stripe, payment_gateway_options: {login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx'})
      provider.settings.allow_finance!
      provider.settings.show_finance!

      @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      login_buyer buyer
    end

    attr_reader :provider, :buyer
    alias current_account buyer

    test '#show' do
      setup_intent = Stripe::SetupIntent.new(id: 'seti_1I5s0l2eZvKYlo2CjumP89gc').tap { |si| si.update_attributes(client_secret: 'seti_1I6Fs82eZvKYlo2COrbF4OYY_secret_IhfCWxVPnPaXIYPlr9ORrd5noJDnDW7') }
      PaymentGateways::StripeCrypt.any_instance.expects(:create_stripe_setup_intent).returns(setup_intent)

      get admin_account_stripe_path

      expected_attributes = {
        'id' => 'stripe-form-wrapper',
        'data-stripe-publishable-key' => provider.payment_gateway_options[:publishable_key],
        'data-setup-intent-secret' => setup_intent.client_secret,
        'data-billing-address' => stripe_billing_address_json,
        'data-success-url' => hosted_success_admin_account_stripe_path,
        'data-credit-card-stored' => buyer.credit_card_stored?
      }.map { |k, v| "@#{k}='#{v}'" }.join(' and ')

      assert_xpath(".//div[#{expected_attributes}]")
    end

    test '#hosted_success' do
      payment_method_id = 'pm_1I5s3n2eZvKYlo2CiO193T69'

      PaymentGateways::StripeCrypt.any_instance.expects(:update!).with(payment_method_id).returns(true)

      post hosted_success_admin_account_stripe_path, params: {stripe: {payment_method_id: payment_method_id}}

      assert_equal 'Credit card details were saved correctly', flash[:success]
    end

    private

    def logged_in?
      !!current_account
    end
  end
end
