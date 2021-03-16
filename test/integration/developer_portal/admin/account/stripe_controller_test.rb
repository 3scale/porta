# frozen_string_literal: true

require 'test_helper'

module DeveloperPortal
  class Admin::Account::StripeControllerTest < ActionDispatch::IntegrationTest
    include System::UrlHelpers.cms_url_helpers

    def setup
      @provider = FactoryBot.create(:provider_account, payment_gateway_type: :stripe, payment_gateway_options: {login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx'})
      provider.settings.allow_finance!
      provider.settings.show_finance!

      @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      login_buyer buyer
    end

    attr_reader :provider, :buyer

    test '#show' do
      setup_intent = Stripe::SetupIntent.new(id: 'seti_1I5s0l2eZvKYlo2CjumP89gc').tap { |si| si.update_attributes(client_secret: 'seti_1I6Fs82eZvKYlo2COrbF4OYY_secret_IhfCWxVPnPaXIYPlr9ORrd5noJDnDW7') }
      PaymentGateways::StripeCrypt.any_instance.expects(:create_stripe_setup_intent).returns(setup_intent)

      get admin_account_stripe_path

      assert_equal provider.payment_gateway_options.fetch(:publishable_key), assigns(:stripe_publishable_key)
      assert_equal setup_intent.id, assigns(:intent).id
      assert_equal setup_intent.client_secret, assigns(:intent).client_secret
    end

    test '#hosted_success' do
      payment_method_id = 'pm_1I5s3n2eZvKYlo2CiO193T69'

      PaymentGateways::StripeCrypt.any_instance.expects(:update!).with(payment_method_id).returns(true)

      post hosted_success_admin_account_stripe_path, params: {stripe: {payment_method_id: payment_method_id}}

      assert_equal 'Credit card details were saved correctly', flash[:success]
    end
  end
end
