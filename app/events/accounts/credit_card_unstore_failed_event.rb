# frozen_string_literal: true

# noinspection SpellCheckingInspection
class Accounts::CreditCardUnstoreFailedEvent < BillingRelatedEvent

  def self.create(buyer, reason)
    new(
      partial_number: buyer.credit_card_partial_number,
      buyer_name: buyer.name,
      gateway_name: buyer.provider_payment_gateway.try!(:display_name),
      reason:,
      metadata: {
        provider_id: buyer.provider_account_id,
      }
    )
  end
end
