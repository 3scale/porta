# frozen_string_literal: true

require 'test_helper'

module Finance
  class ChargingServiceTest < ActiveSupport::TestCase
    class ChargeWithStripeGatewayTest < ActiveSupport::TestCase
      def setup
        @order_id = 3
        @currency = 'EUR'
        @amount = ThreeScale::Money.new(10, currency)
        @buyer_reference = 'cus_IhGaGqpp6zGwyd'
        @common_options = payment_gateway_options.merge(order_id: order_id)
      end

      attr_reader :order_id, :currency, :amount, :buyer_reference, :common_options

      test 'charge with Stripe' do
        stripe_gateway = build_payment_gateway(:stripe)
        service = ChargingService.new(stripe_gateway, buyer_reference: buyer_reference, amount: amount, options: common_options)

        expected_options = common_options.merge(customer: buyer_reference, description: Finance::StripeChargeService::PAYMENT_DESCRIPTION)
        response_params = { 'id' => 'ch_1HxxDgIxGJbGz9puarvnHz6X', 'paid' => true, 'payment_method' => 'card_1HxtiHIxGJbGz9pusM7rTEYS' }
        stripe_gateway.expects(:purchase).with(amount.cents, nil, expected_options).returns(active_merchant_response(response_params))

        assert service.call
      end

      test 'charge with Stripe payment intents (SCA-compliant)' do
        payment_method_id = 'pm_1I5s3n2eZvKYlo2CiO193T69'

        stripe_gateway = build_payment_gateway(:stripe_payment_intents)
        service = ChargingService.new(stripe_gateway, buyer_reference: buyer_reference, amount: amount, options: common_options.merge(payment_method_id: payment_method_id))

        expected_options = common_options.merge(customer: buyer_reference, off_session: true, execute_threed: true, description: Finance::StripeChargeService::PAYMENT_DESCRIPTION)
        response_params = { 'id' => 'pi_1I1EAnIxGJbGz9puiiI6e10D', 'paid' => true, 'payment_method' => payment_method_id }
        stripe_gateway.expects(:purchase).with(amount.cents, payment_method_id, expected_options).returns(active_merchant_response(response_params))

        assert service.call
      end

      private

      def active_merchant_response(params)
        ActiveMerchant::Billing::Response.new(true, 'Transaction approved', params, test: false, authorization: params['id'], error_code: nil)
      end

      def build_payment_gateway(type)
        ActiveMerchant::Billing::Base.gateway(type).new(payment_gateway_options)
      end

      def payment_gateway_options
        { login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx', endpoint_secret: 'some-secret' }
      end
    end
  end

  class ChargeWithBraintreeBlueGatewayTest < ActiveSupport::TestCase
    test 'charge' do
      gateway_options = { merchant_id: 'merchid_braintree', public_key: 'pubkey_braintree', private_key: 'privkey_braintree'}
      gateway = ActiveMerchant::Billing::BraintreeBlueGateway.new(gateway_options)
      amount = ThreeScale::Money.new(45, 'EUR')
      service = ChargingService.new(gateway, buyer_reference: '1234', amount: amount)
      gateway.expects(:purchase).with(amount.cents, '1234', { transaction_source: 'unscheduled' }).returns(true)
      assert service.call
    end
  end
end
