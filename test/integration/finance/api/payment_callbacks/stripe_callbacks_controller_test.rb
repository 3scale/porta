# frozen_string_literal: true

require 'test_helper'

class Finance::Api::PaymentCallbacks::StripeCallbacksControllerTest < ActionDispatch::IntegrationTest
  class CreateTest < self
    setup do
      @provider_account = FactoryBot.create(:simple_provider, payment_gateway_type: :stripe, payment_gateway_options: { login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', endpoint_secret: 'some-secret' })
      provider_account.settings.allow_finance!
      provider_admin = FactoryBot.create(:admin, account: provider_account)
      @access_token = FactoryBot.create(:access_token, owner: provider_admin, scopes: %w[finance])

      buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)
      invoice = FactoryBot.create(:invoice, buyer_account: buyer_account, provider_account: provider_account)
      @payment_intent = FactoryBot.create(:payment_intent, invoice: invoice, reference: 'some-payment-intent-id')

      login! provider_account
    end

    attr_reader :provider_account, :access_token, :payment_intent

    test 'updates existing payment intent' do
      stripe_event = self.stripe_event(type: 'payment_intent.succeeded', payment_intent_data: { id: 'some-payment-intent-id' })
      Stripe::Webhook.expects(:construct_event).returns(stripe_event)

      post api_payment_callbacks_stripe_callbacks_path, params: { access_token: access_token.value }
      assert_response :no_content
    end

    test 'missing stripe webhook signing secret' do
      gateway_options = @provider_account.payment_gateway_setting
      gateway_options.gateway_settings[:endpoint_secret] = ''
      gateway_options.save(validate: false)

      post api_payment_callbacks_stripe_callbacks_path, params: { access_token: access_token.value }
      assert_response :unprocessable_entity
      assert_equal 'Configuration is missing', response.body
    end

    test 'invalid stripe signature' do
      exception = Stripe::SignatureVerificationError.new('invalid signature', 'invalid header content')
      Stripe::Webhook.expects(:construct_event).raises(exception)

      post api_payment_callbacks_stripe_callbacks_path, params: { access_token: access_token.value }
      assert_response :bad_request
    end

    test 'invalid json payload' do
      Stripe::Webhook.expects(:construct_event).raises(JSON::ParserError)

      post api_payment_callbacks_stripe_callbacks_path, params: { access_token: access_token.value }
      assert_response :bad_request
    end

    test 'invalid event' do
      stripe_event = self.stripe_event(type: 'payment_intent.requires_action', payment_intent_data: { id: 'some-payment-intent-id' })
      Stripe::Webhook.expects(:construct_event).returns(stripe_event)

      post api_payment_callbacks_stripe_callbacks_path, params: { access_token: access_token.value }
      assert_response :not_found
    end

    test 'cannot find payment intent' do
      stripe_event = self.stripe_event(type: 'payment_intent.succeeded', payment_intent_data: { id: 'non-existent-payment-intent-id' })
      Stripe::Webhook.expects(:construct_event).returns(stripe_event)

      post api_payment_callbacks_stripe_callbacks_path, params: { access_token: access_token.value }
      assert_response :no_content
    end

    test 'fails to update payment intent' do
      stripe_event = self.stripe_event(type: 'payment_intent.succeeded', payment_intent_data: { id: 'some-payment-intent-id' })
      Stripe::Webhook.expects(:construct_event).returns(stripe_event)
      payment_intent_update_service = Finance::StripePaymentIntentUpdateService.new(provider_account, stripe_event)
      Finance::StripePaymentIntentUpdateService.expects(:new).with(provider_account, stripe_event).returns(payment_intent_update_service)
      payment_intent_update_service.expects(:call).returns(false)
      System::ErrorReporting.expects(:report_error).at_least_once # because the setup doesn't really build all required objects
      System::ErrorReporting.expects(:report_error).with(instance_of(Finance::Api::PaymentCallbacks::StripeCallbacksController::StripeCallbackError), event: stripe_event, payment_intent: payment_intent)

      post api_payment_callbacks_stripe_callbacks_path, params: { access_token: access_token.value }
      assert_response :no_content
    end

    test 'not stripe gateway' do
      provider_account.payment_gateway_type = :bogus
      provider_account.save!

      post api_payment_callbacks_stripe_callbacks_path, params: { access_token: access_token.value }
      assert_response :not_found
    end
  end

  protected

  def stripe_payment_intent_data
    { id: 'payment-intent-id', object: 'payment_intent', status: 'succeeded', amount: 85000, currency: 'eur' }
  end

  def stripe_event_data
    { id: 'event-id', object: 'event', type: 'payment_intent.succeeded', data: { object: stripe_payment_intent_data } }
  end

  def stripe_event(type:, payment_intent_data: {})
    Stripe::Event.construct_from(stripe_event_data.deep_merge(type: type, data: { object: payment_intent_data }))
  end
end
