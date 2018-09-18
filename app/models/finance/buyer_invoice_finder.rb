# frozen_string_literal: true

# Finds an invoice created either by an automatic process `:background` or via manual process (API, UI) `:manual`
class Finance::BuyerInvoiceFinder
  delegate :provider_account, to: :@buyer

  def initialize(buyer:, period:, creation_type: :manual)
    @buyer = buyer
    @period = period
    @creation_type = creation_type
  end

  def find
    @invoice ||= find_invoice || create_invoice
  end

  def self.find(*args)
    new(*args).find
  end

  def find_invoice
    Invoice.by_month(@period.to_param).by_creation_type(@creation_type).opened_by_buyer(@buyer)
  end

  def create_invoice
    @invoice = provider_account.billing_strategy.create_invoice!(buyer_account: @buyer, period: @period, creation_type: @creation_type)
  end
end
