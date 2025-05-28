module Invoices::UnsuccessfullyChargedInvoiceCreatable
  def create(invoice)
    provider = invoice.provider_account

    new(
      invoice:      invoice,
      provider:     provider,
      account_id:   provider.id,
      state:        invoice.state,
      metadata: {
        provider_id: provider.try!(:id)
      }
    )
  end
end
