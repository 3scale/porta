class Finance::Api::Accounts::InvoicesController < Finance::Api::InvoicesController

  ##~ sapi = source2swagger.namespace("Billing API")
  #
  ##~ @base_path = ""
  #
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  ##~
  ##~ e = sapi.apis.add
  ##~ e.path = "/api/accounts/{account_id}/invoices.xml"
  ##~ e.responseClass = "List[invoice]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Invoice List by Account"
  ##~ op.description = "Returns the list of all Invoices by account. Note that results can be paginated and you can apply filters by month and state."
  ##~ op.group = "finance"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_invoice_state
  ##~ op.parameters.add @parameter_invoice_month
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  #

  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/api/accounts/{account_id}/invoices/{id}.xml"
  ##~ e.responseClass = "invoice"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Invoice by Account"
  ##~ op.description = "Returns an Invoice by id."
  ##~ op.group = "finance"
  ##
  ##~ @parameter_invoice_id_by_id = { :name => "id", :description => "ID of the Invoice.", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "path" }
  ##
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_invoice_id_by_id
  #

  private

  def invoices
    @invoices ||= account.invoices
  end

  def account
    @account ||= current_account.buyer_accounts.find(params[:account_id])
  end

end
