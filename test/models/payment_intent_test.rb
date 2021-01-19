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

  private

  def create_payment_intents
    FactoryBot.create_list(:payment_intent, 3, invoice: invoice).sort_by(&:id).reverse
  end

  def relation
    PaymentIntent.where(invoice: invoice)
  end
end
