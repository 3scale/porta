class Invoices::InvoicesToReviewEvent < BillingRelatedEvent

  def self.create(provider)
    new(
      provider:     provider,
      account_id:   provider.id,
      metadata: {
        provider_id: provider.id
      }
    )
  end
end
