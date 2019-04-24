# frozen_string_literal: true

class InvoiceCounter < ApplicationRecord
  belongs_to :provider_account, class_name: 'Account', inverse_of: :buyer_invoice_counters

  validates :invoice_prefix, length: {maximum: 255}

  # FIXME: This is subject to race condition
  def update_count(new_count)
    return if self.invoice_count >= new_count
    self.invoice_count = new_count
    save
  end
end
