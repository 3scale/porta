# frozen_string_literal: true

require 'test_helper'

class PaymentIntentTest < ActiveSupport::TestCase
  setup do
    @invoice = FactoryBot.create(:invoice)
  end

  attr_reader :invoice

  test 'requires an invoice' do
    record = FactoryBot.build(:payment_intent, invoice: nil)
    refute record.valid?
    assert record.errors[:invoice].include?("can't be blank")
    record.invoice = invoice
    assert record.valid?
  end

  test 'requires a payment_intent_id' do
    record = FactoryBot.build(:payment_intent, payment_intent_id: nil)
    refute record.valid?
    assert record.errors[:payment_intent_id].include?("can't be blank")
    record.payment_intent_id = 'foo'
    assert record.valid?
  end

  test 'latest' do
    records = create_payment_intents
    assert_same_elements [records.first], relation.latest
    assert_same_elements records.first(2), relation.latest(2)
  end

  test 'latest_pending' do
    records = create_payment_intents
    records.first.update!(state: 'succeeded')
    assert_same_elements [records.second], relation.latest_pending
    assert_same_elements records[1..-1], relation.latest_pending(2)
  end

  test 'by_invoice' do
    records = create_payment_intents
    other_invoice = FactoryBot.create(:invoice)
    other_record = FactoryBot.create(:payment_intent, invoice: other_invoice)

    assert_same_elements records.map(&:id), PaymentIntent.by_invoice(invoice).pluck(:id)
    assert_same_elements [other_record.id], PaymentIntent.by_invoice(other_invoice).pluck(:id)
  end

  test '#update_from_stripe_event' do
    FactoryBot.create(:line_item, invoice: invoice, cost: 250)
    invoice.send(:issue!)
    invoice_cost = invoice.charge_cost
    payment_intent = FactoryBot.create(:payment_intent, invoice: invoice, state: 'submitted')
    payment_intent_data = { id: payment_intent.payment_intent_id, amount: invoice_cost.cents }
    payment_transactions = invoice.payment_transactions

    invalid_event = stripe_event(type: 'payment_intent.required_action', payment_intent_data: payment_intent_data)
    assert_no_difference(payment_transactions.method(:count)) do
      refute payment_intent.update_from_stripe_event(invalid_event)
      assert_equal 'submitted', payment_intent.reload.state
      refute invoice.reload.paid?
    end

    valid_event = stripe_event(type: 'payment_intent.succeeded', payment_intent_data: payment_intent_data)
    assert_difference(payment_transactions.method(:count)) do
      assert payment_intent.update_from_stripe_event(valid_event)
      assert_equal 'succeeded', payment_intent.reload.state
      assert invoice.reload.paid?
    end
    expected_payment_transaction = { action: 'purchase', amount: invoice_cost, success: true, message: 'Payment confirmed', reference: payment_intent_data[:id], params: valid_event.to_hash }.deep_stringify_keys
    assert_equal expected_payment_transaction, payment_transactions.last.attributes.slice(*%w[action amount success message reference params]).deep_stringify_keys
  end

  private

  def create_payment_intents
    FactoryBot.create_list(:payment_intent, 3, invoice: invoice).sort_by(&:id).reverse
  end

  def relation
    PaymentIntent.where(invoice: invoice)
  end

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
