class Finance::Api::PaymentTransactionsController < Finance::Api::BaseController
  representer PaymentTransaction

  ##~ sapi = source2swagger.namespace("Billing API")
  #
  ##~ @base_path = ""
  #
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices/{invoice_id}/payment_transactions.xml"
  ##~ e.responseClass = "List[payment_transactions]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Invoice Payment Transactions List"
  ##~ op.description = "Returns the list of all payment transactions of an invoice."
  ##~ op.group = "finance"
  #
  ##~ @parameter_access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query", :threescale_name => "access_token" }
  ##~ @parameter_invoice_id = { :name => "invoice_id", :description => "ID of the invoice.", :dataType => "int", :required => true, :paramType => "path" }
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_id
  ##~
  #
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
