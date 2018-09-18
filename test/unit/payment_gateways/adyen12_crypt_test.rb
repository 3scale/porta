require 'test_helper'

module PaymentGateways
  class Adyen12CryptTest < ActiveSupport::TestCase
    include ActiveMerchantTestHelpers
    include ActiveMerchantTestHelpers::Adyen12

    def setup
      user = mock
      @account = mock
      attributes = {
        payment_gateway_type: :adyen12,
        payment_gateway_options: {
          merchantAccount: '12345',
          login: 'hello',
          password: 'world'
        }
      }
      @provider_account = FactoryGirl.build_stubbed(:simple_provider, attributes)
      @payment_gateway = @provider_account.payment_gateway
      @payment_detail = mock

      @account.stubs(provider_account: @provider_account, id: 'account-id', payment_detail: @payment_detail)
      user.stubs(account: @account, email: 'email@example.com')

      @adyen = PaymentGateways::Adyen12Crypt.new(user)
    end

    test '#test? inherits from Active Merchant mode' do
      ActiveMerchant::Billing::Base.stubs(:mode).returns(:test)
      assert @adyen.test?
      assert @adyen.gateway_client.test?

      ActiveMerchant::Billing::Base.stubs(:mode).returns(:production)
      refute @adyen.test?
      refute @adyen.gateway_client.test?
    end

    def test_authorize_with_encrypted_card
      expected_options = {
        shopperEmail: 'email@example.com',
        shopperReference: PaymentGateways::BuyerReferences.buyer_reference(@account, @provider_account),
        shopperIP: nil,
        recurring: 'RECURRING',
        reference: PaymentGateways::BuyerReferences.recurring_authorization_reference(@account, @provider_account),
        shopperIP: '123.124.125.126'
      }

      @payment_gateway.expects(:authorize_recurring).with(0, 'encrypted_data', expected_options)
      @adyen.authorize_with_encrypted_card('encrypted_data', ip: '123.124.125.126')
    end

    def test_retrieve_card_details
      expected_details = {
        'expiryMonth' => '2',
        'expiryYear' => '2017',
        'number' => '0380'
      }
      @payment_gateway.stubs(list_recurring_details: successful_adyen_response)
      assert_equal expected_details, @adyen.retrieve_card_details
    end

    test 'retrieve most recent card details' do
      expected_details = {
        'expiryMonth' => '2',
        'expiryYear' => '2017',
        'number' => '0380'
      }
      @payment_gateway.stubs(list_recurring_details: successful_adyen_response_with_multiples_cards)
      assert_equal expected_details, @adyen.retrieve_card_details
    end

    def test_store_credit_card_details_successful
      details = {
        'expiryMonth' => '2',
        'expiryYear' => '2017',
        'number' => '0380',
        'recurringDetailReference' => '8313147988756818'
      }
      @adyen.stubs(authorize_response: successful_adyen_authorization_response, retrieve_card_details: details)

      reference = PaymentGateways::BuyerReferences.buyer_reference(@account, @provider_account)
      expected_payment_details = {
        credit_card_partial_number: '0380',
        credit_card_expires_on: Time.zone.local(2017, 2, 1).to_datetime.to_date,
        buyer_reference: reference,
        payment_service_reference: '8313147988756818',
      }
      @payment_detail.expects(:update_attributes).with(expected_payment_details)

      @adyen.store_credit_card_details
    end

    def test_store_credit_card_details_failing
      @adyen.stubs(authorize_response: successful_adyen_authorization_response, retrieve_card_details: {})

      @payment_detail.expects(:update_attributes).never
      @account.expects(:save).never

      @adyen.store_credit_card_details
    end

    def test_store_credit_card_details_with_gateway_response
      @adyen.stubs(authorize_response: successful_adyen_authorization_response_with_card_alias('H123456789012345'))

      credit_card_details = {
        'expiryMonth' => '2',
        'expiryYear' => '2017',
        'number' => '0380',
        'recurringDetailReference' => '8313147988756818'
      }
      @adyen.expects(:retrieve_card_details_with_alias).with('H123456789012345').returns(credit_card_details)

      reference = PaymentGateways::BuyerReferences.buyer_reference(@account, @provider_account)
      expected_payment_details = {
        credit_card_partial_number: '0380',
        credit_card_expires_on: Time.zone.local(2017, 2, 1).to_datetime.to_date,
        buyer_reference: reference,
        payment_service_reference: '8313147988756818',
      }
      @payment_detail.expects(:update_attributes).with(expected_payment_details)

      @adyen.store_credit_card_details
    end

    def test_store_card_details_without_authorizing_first
      @adyen.expects(:authorize_response).returns(nil)

      credit_card_details = {
        'expiryMonth' => '2',
        'expiryYear' => '2017',
        'number' => '0380',
        'recurringDetailReference' => '8313147988756818'
      }
      @adyen.expects(:retrieve_card_details).returns(credit_card_details)

      reference = PaymentGateways::BuyerReferences.buyer_reference(@account, @provider_account)
      expected_payment_details = {
        credit_card_partial_number: '0380',
        credit_card_expires_on: Time.zone.local(2017, 2, 1).to_datetime.to_date,
        buyer_reference: reference,
        payment_service_reference: '8313147988756818',
      }
      @payment_detail.expects(:update_attributes).with(expected_payment_details)

      @adyen.store_credit_card_details
    end

    def test_authorize_recurring_and_store_card_details
      params = [
        'adyen-encrypted-card-data',
        ip: '127.0.0.1'
      ]
      @adyen.expects(:authorize_with_encrypted_card).with(*params).returns(successful_adyen_authorization_response)
      @adyen.expects(:store_credit_card_details)
      @adyen.authorize_recurring_and_store_card_details(*params)
    end
  end
end
