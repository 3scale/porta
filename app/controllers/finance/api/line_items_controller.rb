# frozen_string_literal: true

class Finance::Api::LineItemsController < Finance::Api::BaseController
  representer LineItem
  wrap_parameters LineItem, include: %i[name description quantity cost contract_id metric_id plan_id cinstance_id type]

  ##~ sapi = source2swagger.namespace("Billing API")
  #
  ##~ @base_path = ""
  #
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices/{invoice_id}/line_items.xml"
  ##~ e.responseClass = "List[line_items]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Invoice Line Items List"
  ##~ op.description = "Returns the list of all Line Items of an Invoice."
  ##~ op.group = "finance"
  #
  ##~ @parameter_access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query", :threescale_name => "access_token" }
  ##~ @parameter_invoice_id = { :name => "invoice_id", :description => "ID of the Invoice.", :dataType => "int", :required => true, :paramType => "path" }
  ##~ @parameter_line_item_id_by_id = { :name => "id", :description => "ID of the Line Item.", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "path" }
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_id
  ##~
  #
  def index
    respond_with(line_items)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices/{invoice_id}/line_items.xml"
  ##~ e.responseClass = "line_item"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Create Line Item for an Invoice"
  ##~ op.description = "Creates a new Line Item for an Invoice."
  ##~ op.group = "finance"
  #
  ##~ @parameter_line_item_name = { :name => "name", :description => "Name of the Line Item", "required" => false, :paramType => "query"}
  ##~ @parameter_line_item_description = { :name => "description", :description => "Description of the Line Item", "required" => false, :paramType => "query"}
  ##~ @parameter_line_item_quantity = { :name => "quantity", :description => "Quantity of the Line Item", "required" => false, :paramType => "query"}
  ##~ @parameter_line_item_cost = { :name => "cost", :description => "Total cost/price of the Line Item considering the quantity", "required" => false, :paramType => "query"}
  ##~ @parameter_line_item_metric_id = { :name => "metric_id", :description => "Metric that have generated this Line Item", "required" => false, :paramType => "query"}
  ##~ @parameter_line_item_contract_id = { :name => "contract_id", :description => "Contract that have generated this Line Item", "required" => false, :paramType => "query"}
  ##~ @parameter_line_item_type = { :name => "type", :description => "Type of cost. Can be [LineItem::PlanCost, LineItem::VariableCost]", "required" => false, :paramType => "query"}
  ##~ @parameter_line_item_plan_id = { :name => "plan_id", :description => "The ID of the plan.", "required" => false, :paramType => "query"}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_id
  ##~ op.parameters.add @parameter_line_item_name
  ##~ op.parameters.add @parameter_line_item_description
  ##~ op.parameters.add @parameter_line_item_quantity
  ##~ op.parameters.add @parameter_line_item_cost
  ##~ op.parameters.add @parameter_line_item_metric_id
  ##~ op.parameters.add @parameter_line_item_contract_id
  ##~ op.parameters.add @parameter_line_item_type
  ##~ op.parameters.add @parameter_line_item_plan_id
  #
  def create
    line_item = billing.create_line_item(line_item_params)
    respond_with(line_item)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/api/invoices/{invoice_id}/line_items/{id}.xml"
  ##~ e.responseClass = "line_item"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Delete Line Item of an Invoice"
  ##~ op.description = "Deletes a Line Item of an Invoice."
  ##~ op.group = "finance"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_invoice_id
  ##~ op.parameters.add @parameter_line_item_id_by_id
  #
  def destroy
    billing.destroy_line_item(line_item)
    respond_with(line_item)
  end

  private

  def billing
    @billing ||= Finance::AdminBilling.new(invoice)
  end

  def invoice
    @invoice ||= current_account.buyer_invoices.find(params[:invoice_id])
  end

  def line_item
    @line_item ||= invoice.line_items.find(params[:id])
  end

  def line_items
    @line_items ||= invoice.line_items
  end

  def line_item_params
    params.permit(:name, :description, :quantity, :cost).merge(
      contract_id: contract_id, contract_type: contract_type, metric: metric, plan_id: plan_id, type: cost_type,
      cinstance_id: cinstance_id
    )
  end

  def metric
    metric_id = params.require(:line_item)[:metric_id]
    Metric.joins(:service).merge(current_account.services).find(metric_id) if metric_id.present?
  end

  def contract_id
    contract_id = params.require(:line_item)[:contract_id]
    invoice.buyer_account.contracts.find(contract_id).id if contract_id.present?
  end

  def contract_type
    contract_id = params.require(:line_item)[:contract_id]
    invoice.buyer_account.contracts.find(contract_id).class.name if contract_id.present?
  end

  def plan_id
    plan_id = params.require(:line_item)[:plan_id]
    invoice.buyer_account.bought_plans.find(plan_id).id if plan_id.present?
  end

  def cinstance_id
    cinstance_id = params.require(:line_item)[:cinstance_id]
    invoice.buyer_account.bought_cinstances.find(cinstance_id).id if cinstance_id.present?
  end

  def cost_type
    params.require(:line_item)[:type]
  end
end
