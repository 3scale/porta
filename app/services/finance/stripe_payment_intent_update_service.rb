# frozen_string_literal: true

class Finance::StripePaymentIntentUpdateService
  def initialize(provider_account, stripe_event)
    @stripe_event = stripe_event
    @payment_intent_data = stripe_event.data.object
    @payment_intent = PaymentIntent.by_invoice(provider_account.buyer_invoices).find_by!(reference: payment_intent_data['id'])
  end

  attr_reader :stripe_event, :payment_intent_data, :payment_intent

  delegate :invoice, :succeeded?, to: :payment_intent
  delegate :payment_transactions, to: :invoice

  def call
    payment_intent.with_lock do
      payment_intent.state = payment_intent_status
      next true unless payment_intent.changed?
      payment_intent.save && create_payment_transaction && (!succeeded? || invoice.pay)
    end
  end

  protected

  def payment_intent_status
    payment_intent_data['status']
  end

  def create_payment_transaction
    attributes = {
      action: :purchase,
      amount: ThreeScale::Money.cents(payment_intent_data['amount'].presence || 0, payment_intent_data['currency']&.upcase || invoice.currency),
      reference: payment_intent_data['id'],
      success: succeeded?,
      message: succeeded? ? 'Payment confirmed' : payment_intent_status.humanize,
      params: stripe_event.to_hash
    }

    payment_transactions.create(attributes, without_protection: true)
  end
end
