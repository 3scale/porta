# frozen_string_literal: true

module InvoiceHelpers
  def tested_invoice_date
    Date.parse 'December, 2022'
  end
end

World(InvoiceHelpers)
