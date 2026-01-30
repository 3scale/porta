# frozen_string_literal: true

module Accounts::InvoicesHelper
  def admin_buyers_or_account_invoice_path(invoice, account)
    if current_account.provider? && account
      admin_buyers_account_invoice_path(account, invoice)
    else
      admin_account_invoice_path(invoice)
    end
  end
end
