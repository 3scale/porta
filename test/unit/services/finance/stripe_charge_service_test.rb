# frozen_string_literal: true

require 'test_helper'

class Finance::StripeChargeServiceTest < ActiveSupport::TestCase
  setup do
    provider_account = FactoryBot.create(:simple_provider, payment_gateway_type: :stripe, payment_gateway_options: { login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc' })
    buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)
    @gateway = provider_account.payment_gateway(sca: true)
    @amount = ThreeScale::Money.new(150.0, 'EUR')
    line_item = FactoryBot.create(:line_item, cost: amount.amount)
    @invoice = FactoryBot.create(:invoice, buyer_account: buyer_account, provider_account: provider_account, line_items: [line_item])
    @service = build_charge_service(invoice: invoice)
  end

  attr_reader :gateway, :invoice, :amount, :service

  test 'charge' do
    service.expects(:create_payment_intent).with(amount).returns(true)
    assert service.charge(amount)
  end

  test 'charge with existing payment intent' do
    payment_intent = FactoryBot.create(:payment_intent, invoice: invoice, reference: 'some-payment-intent-id', state: 'pending')
    service.expects(:confirm_payment_intent).with(payment_intent).returns(true)
    assert service.charge(amount)
  end

  test 'create payment intent' do
    response = build_response(true, 'Transaction Approved', object: 'payment_intent', id: 'new-payment-intent-id', status: 'succeeded')
    gateway.expects(:purchase).returns(response)

    assert_difference(invoice.payment_intents.method(:count)) do
      assert_equal response, service.send(:create_payment_intent, amount)
      assert (payment_intent = invoice.payment_intents.latest.first)
      assert_equal 'new-payment-intent-id', payment_intent.reference
      assert_equal 'succeeded', payment_intent.state
      refute invoice.latest_pending_payment_intent
    end
  end

  test 'new payment intent requires action' do
    response = build_response(false, 'Authentication required', status: 'authentication_required', error: { payment_intent: { object: 'payment_intent', id: 'new-payment-intent-id', status: 'requires_payment_method' } })
    gateway.expects(:purchase).returns(response)

    assert_difference(invoice.payment_intents.method(:count)) do
      assert_equal response, service.send(:create_payment_intent, amount)
      assert (payment_intent = invoice.latest_pending_payment_intent)
      assert_equal 'new-payment-intent-id', payment_intent.reference
      assert_equal 'requires_payment_method', payment_intent.state
    end
  end

  test 'new payment intent requires confirmation' do
    response = build_response(false, 'Authentication required', status: 'authentication_required', error: { payment_intent: { object: 'payment_intent', id: 'new-payment-intent-id', status: 'requires_confirmation' } })
    gateway.expects(:purchase).returns(response)

    payment_intent = FactoryBot.create(:payment_intent, invoice: invoice, reference: 'new-payment-intent-id', state: 'requires_confirmation')
    invoice.payment_intents.expects(:create!).returns(payment_intent)

    service.expects(:confirm_payment_intent).with(payment_intent).returns(true)
    assert_equal response, service.send(:create_payment_intent, amount)
  end

  test 'create with error' do
    response = build_response(false, 'Failed', status: 'failed', error: { message: 'No error details' })
    gateway.expects(:purchase).returns(response)

    assert_no_difference(invoice.payment_intents.method(:count)) do
      assert_equal response, service.send(:create_payment_intent, amount)
    end
  end

  test 'create payment intent without invoice' do
    response = build_response(true, 'Transaction Approved', object: 'payment_intent', id: 'new-payment-intent-id', status: 'succeeded')
    gateway.expects(:purchase).returns(response)

    assert_no_difference(invoice.payment_intents.method(:count)) do
      assert_equal response, build_charge_service.send(:create_payment_intent, amount)
    end
  end

  test 'successful confirm payment intent' do
    payment_intent_reference = 'some-payment-intent-id'
    payment_intent = FactoryBot.create(:payment_intent, invoice: invoice, reference: payment_intent_reference, state: 'pending')

    response = build_response(true, 'Transaction Approved', object: 'payment_intent', id: payment_intent_reference, status: 'succeeded')
    gateway.expects(:confirm_intent).with(payment_intent_reference, service.payment_method_id, service.gateway_options).returns(response)

    assert_equal 'pending', payment_intent.state
    assert_equal response, service.send(:confirm_payment_intent, payment_intent)
    assert_equal 'succeeded', payment_intent.reload.state
  end

  test 'failed confirm payment intent' do
    payment_intent_reference = 'some-payment-intent-id'
    payment_intent = FactoryBot.create(:payment_intent, invoice: invoice, reference: payment_intent_reference, state: 'pending')

    response = build_response(true, 'Transaction Approved', object: 'payment_intent', id: 'some-payment-intent-id', status: 'requires_payment_method')
    gateway.expects(:confirm_intent).with(payment_intent_reference, service.payment_method_id, service.gateway_options).returns(response)

    assert_equal 'pending', payment_intent.state
    assert service.send(:confirm_payment_intent, payment_intent)
    refute response.success?
    assert_equal 'Requires payment method', response.message
    assert_equal 'requires_payment_method', payment_intent.reload.state
  end

  test 'has payment intent description' do
    invoice.update({friendly_id: '2022-10-00000001'})
    invoice.issue_and_pay_if_free!
    with_invoice = build_charge_service(invoice: invoice)
    assert_equal "#{invoice.provider.name} API services 2022-10-00000001", with_invoice.send(:charge_description)

    without_invoice = build_charge_service
    assert_equal 'API services', without_invoice.send(:charge_description)
  end

  test 'sends payment intent description to the gateway' do
    response = build_response(true, 'Transaction Approved', object: 'payment_intent', id: 'new-payment-intent-id', status: 'succeeded')
    invoice.issue_and_pay_if_free!
    gateway.expects(:purchase).with(15000, anything, has_entry(:description, "#{invoice.provider.name} API services fix")).returns(response)

    assert service.charge(amount)
  end

  private

  def build_charge_service(opts = {})
    gateway_options = { customer: 'a-customer-id', off_session: true, execute_threed: true }
    options = { payment_method_id: 'a-payment-method-id', gateway_options: gateway_options }
    Finance::StripeChargeService.new(gateway, **options.deep_merge(opts))
  end

  def build_response(success, message, params)
    ActiveMerchant::Billing::Response.new(success, message, params.deep_stringify_keys)
  end
end
