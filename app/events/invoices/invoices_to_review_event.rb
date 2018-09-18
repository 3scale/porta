class Invoices::InvoicesToReviewEvent < BillingRelatedEvent

  def self.create(provider)
    new(
      provider: provider,
      metadata: {
        provider_id: provider.id
      }
    )
  end
end
