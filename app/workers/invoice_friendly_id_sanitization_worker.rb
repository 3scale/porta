# frozen_string_literal: true

class InvoiceFriendlyIdSanitizationWorker
  include Sidekiq::Worker

  sidekiq_options queue: :billing

  def perform(provider_account_id)
    provider_account = Account.providers_with_master.find(provider_account_id)
    provider_account.buyer_invoices.where('friendly_id IS NULL OR friendly_id = ?', 'fix').find_each do |invoice|
      InvoiceFriendlyIdService.call!(invoice)
    end
  end
end
