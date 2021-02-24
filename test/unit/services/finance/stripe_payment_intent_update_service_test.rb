# frozen_string_literal: true

require 'test_helper'

class Finance::StripePaymentIntentUpdateServiceTest < ActiveSupport::TestCase
  setup do
    @provider_account = FactoryBot.create(:simple_provider)
    buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)
    @invoice = FactoryBot.create(:invoice, buyer_account: buyer_account, provider_account: provider_account)
    FactoryBot.create(:line_item, invoice: invoice, cost: 250)
    invoice.send(:issue!)
    @payment_intent = FactoryBot.create(:payment_intent, invoice: invoice, state: 'submitted')
  end

  attr_reader :provider_account, :invoice, :payment_intent

  test 'succeeded' do
    stripe_event = build_stripe_event(type: 'payment_intent.succeeded', payment_intent_data: { status: 'succeeded' })
    service = Finance::StripePaymentIntentUpdateService.new(provider_account, stripe_event)

    assert_difference(payment_transactions.method(:count)) do
      assert service.call
      assert_equal 'succeeded', payment_intent.reload.state
      assert invoice.reload.paid?
    end

    expected_payment_transaction = { action: 'purchase', amount: charge_cost, success: true, message: 'Payment confirmed', reference: payment_intent_data[:id], params: stripe_event.to_hash }.deep_stringify_keys
    assert_equal expected_payment_transaction, payment_transactions.last.attributes.slice(*%w[action amount success message reference params]).deep_stringify_keys
  end

  test 'not succeeded' do
    stripe_event = build_stripe_event(type: 'payment_intent.requires_action', payment_intent_data: { status: 'requires_action' })
    service = Finance::StripePaymentIntentUpdateService.new(provider_account, stripe_event)

    assert_difference(payment_transactions.method(:count)) do
      assert service.call
      assert_equal 'requires_action', payment_intent.reload.state
      refute invoice.reload.paid?
    end

    expected_payment_transaction = { action: 'purchase', amount: charge_cost, success: false, message: 'Requires action', reference: payment_intent_data[:id], params: stripe_event.to_hash }.deep_stringify_keys
    assert_equal expected_payment_transaction, payment_transactions.last.attributes.slice(*%w[action amount success message reference params]).deep_stringify_keys
  end

  test 'skips when there is no change to the payment intent state' do
    payment_intent.update!(state: Finance::StripeChargeService::PAYMENT_INTENT_SUCCEEDED)

    stripe_event = build_stripe_event(type: 'payment_intent.succeeded', payment_intent_data: { status: 'succeeded' })
    service = Finance::StripePaymentIntentUpdateService.new(provider_account, stripe_event)

    assert_no_difference(payment_transactions.method(:count)) do
      assert service.call
    end
  end

  protected

  def stripe_event_data
    { id: 'event-id', object: 'event', type: 'payment_intent.succeeded', data: { object: { id: 'payment-intent-id', object: 'payment_intent', status: 'succeeded', amount: 85000, currency: 'eur' } } }
  end

  def payment_intent_data
    { id: payment_intent.reference, amount: charge_cost.cents }
  end

  def build_stripe_event(type:, payment_intent_data: {})
    payment_intent_object = self.payment_intent_data.merge(payment_intent_data)
    Stripe::Event.construct_from(stripe_event_data.deep_merge(type: type, data: { object: payment_intent_object }))
  end

  delegate :payment_transactions, :charge_cost, to: :invoice
end
