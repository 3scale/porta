# frozen_string_literal: true

class InvoiceFriendlyIdWorker
  include Sidekiq::Worker

  sidekiq_options queue: :billing

  def perform(invoice_id)
    invoice = Invoice.find invoice_id
    InvoiceFriendlyIdService.call!(invoice)
  end
end
