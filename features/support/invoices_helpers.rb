# frozen_string_literal: true

module InvoicesHelpers
  def create_invoice(buyer, date = Time.zone.now, opts = {})
    options = opts.reverse_merge(buyer_account: buyer, period: Month.new(date), creation_type: :background)
    buyer.provider_account.billing_strategy.create_invoice!(options)
  end

  def assert_secure_invoice_pdf_url(url, invoice)
    assert url.ends_with?(invoice.pdf.expiring_url)
  end
end

World(InvoicesHelpers)
