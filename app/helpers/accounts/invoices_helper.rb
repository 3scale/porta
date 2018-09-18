module Accounts::InvoicesHelper
  def admin_buyers_or_account_invoice_path invoice
    if current_account.provider? && @account
      admin_buyers_account_invoice_path @account, invoice
    else
      admin_account_invoice_path invoice
    end
  end

  def create_invoice_disabled(account)
    if @account.current_invoice
      "You cannot create a new invoice for '#{account.name}' since it already has one open. Please issue it before creating a new one."
    end
  end
end
