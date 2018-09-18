class Finance::Api::InvoicesController < Finance::Api::BaseController

  representer ::Invoice

  paginate only: :index

  STATES = Hash.new {|_, k| k}.merge('cancel' => 'cancelled').freeze

  ##~ sapi = source2swagger.namespace("Billing API")
  #
  ##~ @base_path = ""
  #
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices.xml"
  ##~ e.responseClass = "List[invoice]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Invoice List"
  ##~ op.description = "Returns the list of all Invoices. Note that results can be paginated and you can apply filters by month and state."
  ##~ op.group = "finance"
  ##~
  ##~ @parameter_access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query", :threescale_name => "access_token" }
  ##~ @parameter_invoice_id_by_id = { :name => "id", :description => "ID of the Invoice.", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "path" }
  ##~ @parameter_page = {:name => "page", :description => "Page in the paginated list. Defaults to 1.", :dataType => "int", :paramType => "query", :defaultValue => "1"}
  ##~ @parameter_per_page = {:name => "per_page", :description => "Number of results per page. Default and max is 20.", :dataType => "int", :paramType => "query", :defaultValue => "20"}
  ##~ @parameter_invoice_state = {:name => "state", :description => "Filter Invoices by state. 'open': line items can be added (via web interface). 'pending': the Invoice has been issued, no items can be added, the PDF has been generated and the Invoice is waiting to be charged. 'paid': sucessfully paid. 'unpaid': charging failed at least once. 'cancelled': the Invoice was explicitly cancelled and is out of the normal life-cycle.", :dataType => "string", :paramType => "query", :required => false, :defaultValue => "", :allowableValues => { :values => ["open", "pending", "paid", "unpaid", "cancelled"], :valueType => "LIST" }}
  ##~ @parameter_invoice_month = {:name => "month", :description => "Filter Invoices by month. Format YYYY-MM, e.g. '2012-03'.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_account_id = {:name => "account_id", :description => "ID of the account.", :dataType => "int", :required => true, :paramType => "query", :threescale_name => "account_ids"}
  ##~ parameter_period = { :name => "period", :description => "Billing period of the Invoice. The format should be YYYY-MM.", "required" => false, :paramType => "query"}
  ##~ @parameter_friendly_id = { :name => "friendly_id", :description => "Friendly ID of the Invoice. The format should be YYYY-MM-XXXXXXXX or YYYY-XXXXXXXX.", "required" => false, :paramType => "query"}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_state
  ##~ op.parameters.add @parameter_invoice_month
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  ##~
  #
  def index
    search = ThreeScale::Search.new(params[:search] || params)
    results = invoices.scope_search(search)
                .order_by(params[:sort], params[:direction])
                .paginate(pagination_params)

    respond_with(results)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices/{id}.xml"
  ##~ e.responseClass = "Invoice"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Invoice Read"
  ##~ op.description = "Returns an Invoice by ID."
  ##~ op.group = "finance"
  #
  ##
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_id_by_id
  #
  def show
    respond_with(invoice) do |format|
      format.pdf { redirect_to invoice.pdf.url }
    end
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices/{id}/state.xml"
  ##~ e.responseClass = "invoice"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Invoice Update state"
  ##~ op.description = "Modifies the state of the Invoice."
  ##~ op.group = "finance"
  #
  ##~ @parameter_state = { :name => "state", :description => "State of the Invoice to set. Values allowed (depend on the previous state): cancelled, failed, paid, unpaid, pending, finalized", :dataType => "string", :required => true, :paramType => "query", :threescale_name => "state"}
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_id_by_id
  ##~ op.parameters.add @parameter_state
  #
  def state
    state = STATES[params[:state]]
    transition = invoice.next_transition_from_state(state)
    if transition
      invoice.fire_state_event(transition.event)
    else
      invoice.errors.add(:base, "Cannot transition to #{state}")
    end
    respond_with(invoice)
  end


  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices/{id}/charge.xml"
  ##~ e.responseClass = "invoice"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Invoice Charge"
  ##~ op.description = "Charge an Invoice."
  ##~ op.group = "finance"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_id_by_id
  #
  def charge
    errors = invoice.errors
    if invoice.transition_allowed?(:charge)
      errors.add(:base, :charging_failed) unless invoice.charge!(false)
    else
      errors.add(:state, :not_in_chargeable_state, id: invoice.id)
    end
    respond_with(invoice)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices/{id}.xml"
  ##~ e.responseClass = "invoice"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Invoice Update"
  ##~ op.description = "Updates an Invoice."
  ##~ op.group = "finance"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_id_by_id
  ##~ op.parameters.add @parameter_period
  ##~ op.parameters.add @parameter_friendly_id
  #
  def update
    invoice.update_attributes(invoice_params_update, without_protection: true)
    respond_with(invoice)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices.xml"
  ##~ e.responseClass = "invoice"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Invoice Create"
  ##~ op.description = "Creates a new Invoice."
  ##~ op.group = "finance"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id
  ##~ op.parameters.add parameter_period
  #
  def create
    new_invoice = current_account.billing_strategy.create_invoice(invoice_params_create)
    respond_with(new_invoice)
  end

  private

  def invoices
    @invoices ||= current_account.buyer_invoices.includes(:line_items, {:buyer_account => [:country]}, :provider_account)
  end

  def invoice
    @invoice ||= invoices.find(params[:id])
  end

  def invoice_params_create
    params.fetch(:invoice).permit(:period).merge( buyer_account: find_buyer(params.require(:account_id)) )
  end

  def invoice_params_update
    params.require(:invoice).permit(:period, :friendly_id)
  end

  def find_buyer(account_id)
    current_account.buyer_accounts.find_by(id: account_id)
  end

end
