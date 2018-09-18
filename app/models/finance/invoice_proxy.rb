# frozen_string_literal: true

# This class should not be used directly in the API or in the UI.
# It will fetch the first invoice that is generated automatically or create one
# corresponding to the provider, buyer and period

class Finance::InvoiceProxy

  attr_reader :provider, :buyer, :month
  delegate :line_items, :to => :invoice
  delegate :check_editable_line_items, to: :invoice

  def initialize(buyer, month)
    @buyer = buyer
    @month = month
    @used = false
  end

  # Returns true if it was actually used to bill something.
  def used?
    @used
  end

  def mark_as_used
    @used = true
  end

  def should_bill?
    @buyer.billing_monthly?
  end

  private

  def invoice
    @invoice ||= Finance::BuyerInvoiceFinder.find(buyer: @buyer, period: @month, creation_type: :background)
  end
end
