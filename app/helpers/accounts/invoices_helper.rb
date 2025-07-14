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
      I18n.t('buyers.invoices.create.open_invoice', name: account.name)
    end
  end
end
