require 'test_helper'

module PaymentGateways
  class AuthorizeNetCimCryptTest < ActiveSupport::TestCase

    include ActiveMerchantTestHelpers
    include ActiveMerchantTestHelpers::AuthorizeNet

    def setup
      user = mock

      @account = mock
      attributes = {
        payment_gateway_type: :authorize_net,
        payment_gateway_options: {
          merchantAccount: '12345',
          login: 'hello',
          password: 'world'
        }
      }

      @provider_account = FactoryGirl.build_stubbed(:simple_provider, attributes)
      @payment_gateway = @provider_account.payment_gateway

      @account.stubs(provider_account: @provider_account, id: 'account-id')
      user.stubs(account: @account, email: 'email@example.com')

      @authorize_net = PaymentGateways::AuthorizeNetCimCrypt.new(user)
    end

    test '#test? inherits from Active Merchant mode' do
      ActiveMerchant::Billing::Base.stubs(:mode).returns(:test)
      assert @authorize_net.test?
      assert @authorize_net.provider.payment_gateway.cim_gateway.test?

      ActiveMerchant::Billing::Base.stubs(:mode).returns(:production)
      refute @authorize_net.test?
      refute @authorize_net.provider.payment_gateway.cim_gateway.test?
    end

    test '#authorize_api_url in production' do
      @authorize_net.stubs(:test? => false)
      assert_equal 'https://api2.authorize.net/xml/v1/request.api', @authorize_net.authorize_api_url
    end

    test '#authorize_api_url in test' do
      @authorize_net.stubs(:test? => true)
      assert_equal 'https://apitest.authorize.net/xml/v1/request.api', @authorize_net.authorize_api_url
    end

    test '#form_url in production' do
      @authorize_net.stubs(:test? => false)
      assert_equal 'https://secure.authorize.net/profile', @authorize_net.form_url
    end

    test '#form_url in test' do
      @authorize_net.stubs(:test? => true)
      assert_equal 'https://test.authorize.net/profile', @authorize_net.form_url
    end

    test '#payment_profile failed' do
      @account.stubs(credit_card_auth_code: 56565656)

      ActiveMerchant::Billing::AuthorizeNetCimGateway.any_instance.stubs(:get_customer_profile).returns(failed_get_customer_profile_response)
      assert_nil @authorize_net.payment_profile
    end

    test '#payment_profile succeed' do
      @account.stubs(credit_card_auth_code: 56565656)
      ActiveMerchant::Billing::AuthorizeNetCimGateway.any_instance.stubs(:get_customer_profile).returns(successful_get_customer_profile_response)
      assert_equal 12345, @authorize_net.payment_profile
    end

    test '#update_user' do
      account = FactoryGirl.create :simple_account
      @authorize_net.stubs(account: account)
      @authorize_net.update_user(successful_get_customer_profile_response)

      assert_equal '4444', account.credit_card_partial_number
      assert_nil account.credit_card_expires_on

      assert_equal "3scale", account.billing_address_name
      assert_equal "Carrer Napols", account.billing_address_address1
      assert_equal "Barcelona", account.billing_address_city
      assert_equal "Spain", account.billing_address_country
      assert_equal "Barcelona", account.billing_address_state
      assert_equal "08013", account.billing_address_zip
      assert_equal "+34123456789", account.billing_address_phone
    end

    test '#create_profile' do
      json_string = <<-JSON
      {
        "messages": {
          "result_code": "Ok"
        },
         "customer_profile_id": "#{@authorize_net.buyer_reference}"
      }
      JSON
      successful_create_customer_profile_response = build_active_merchant_response(true, json_string)

      ActiveMerchant::Billing::AuthorizeNetCimGateway.any_instance
        .expects(:create_customer_profile).with(profile: {email: 'email@example.com', description: @authorize_net.buyer_reference})
        .returns(successful_create_customer_profile_response)
      @account.expects(:credit_card_auth_code=).with(@authorize_net.buyer_reference)

      @account.expects(:save!)
      @authorize_net.create_profile
    end

    test '#has_credit_card?' do
      refute @authorize_net.has_credit_card?(failed_get_customer_profile_response)
      response = successful_get_customer_profile_response
      response.stubs(success?: false)
      refute @authorize_net.has_credit_card?(response)
      assert @authorize_net.has_credit_card?(successful_get_customer_profile_response)
    end
  end
end
