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

  test 'requires a reference' do
    record = FactoryBot.build(:payment_intent, reference: nil)
    refute record.valid?
    assert record.errors[:reference].include?("can't be blank")
    record.reference = 'foo'
    assert record.valid?
  end

  test 'latest' do
    records = create_payment_intents
    assert_same_elements [records.first], relation.latest
    assert_same_elements records.first(2), relation.latest(2)
  end

  test 'pending' do
    records = create_payment_intents
    records.first.update!(state: 'succeeded')
    assert_same_elements records[1..-1], relation.pending
  end

  test 'by_invoice' do
    records = create_payment_intents
    other_invoice = FactoryBot.create(:invoice)
    other_record = FactoryBot.create(:payment_intent, invoice: other_invoice)

    assert_same_elements records.map(&:id), PaymentIntent.by_invoice(invoice).pluck(:id)
    assert_same_elements [other_record.id], PaymentIntent.by_invoice(other_invoice).pluck(:id)
  end

  private

  def create_payment_intents
    FactoryBot.create_list(:payment_intent, 3, invoice: invoice).sort_by(&:id).reverse
  end

  def relation
    PaymentIntent.where(invoice: invoice)
  end
end
