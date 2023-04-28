class Finance::Api::Accounts::InvoicesController < Finance::Api::InvoicesController

  # Invoice List by Account
  # GET /api/accounts/{account_id}/invoices.xml

  # Invoice by Account
  # GET /api/accounts/{account_id}/invoices/{id}.xml

  private

  def invoices
    @invoices ||= account.invoices
  end

  def account
    @account ||= current_account.buyer_accounts.find(params[:account_id])
  end

end
