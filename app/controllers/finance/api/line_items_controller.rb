# frozen_string_literal: true

class Finance::Api::LineItemsController < Finance::Api::BaseController
  representer LineItem
  wrap_parameters LineItem, include: %i[name description quantity cost contract_id metric_id plan_id cinstance_id type]

  # Invoice Line Items List
  # GET /api/invoices/{invoice_id}/line_items.xml
  def index
    respond_with(line_items)
  end

  # Create Line Item for an Invoice
  # POST /api/invoices/{invoice_id}/line_items.xml
  def create
    line_item = billing.create_line_item(line_item_params)
    respond_with(line_item)
  end

  # Delete Line Item of an Invoice
  # DELETE /api/invoices/{invoice_id}/line_items/{id}.xml
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
