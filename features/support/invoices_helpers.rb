module InvoicesHelpers
  def create_invoice(buyer, date, opts = {})
    options = opts.reverse_merge(buyer_account: buyer, period: Month.new(date), creation_type: :background)
    buyer.provider_account.billing_strategy.create_invoice!(options)
  end

  def assert_secure_invoice_pdf_url(url, invoice)
    assert_equal invoice.pdf.expiring_url, url
  end
end

World(InvoicesHelpers)
