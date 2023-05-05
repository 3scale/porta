class Finance::Api::PaymentTransactionsController < Finance::Api::BaseController
  representer PaymentTransaction

  # Invoice Payment Transactions List
  # GET /api/invoices/{invoice_id}/payment_transactions.xml
  def index
    respond_with(payment_transactions)
  end

  private

  def invoice
    @invoice ||= current_account.buyer_invoices.find params[:invoice_id]
  end

  def payment_transactions
    @payment_transactions ||= invoice.payment_transactions
  end

end
