module InvoiceRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  property :friendly_id
  property :created_at
  property :updated_at

  property :state

  property :paid_at
  property :due_on
  property :issued_on
  property :currency
  property :cost
  property :vat_rate, render_nil: true
  property :vat_amount
  property :cost_without_vat

  property :period
  property :creation_type

  def cost
    super.to_f
  end

  def vat_amount
    super.to_f
  end

  def vat_rate
    super&.to_f
  end

  def cost_without_vat
    exact_cost_without_vat.to_f
  end

  link :account do
    admin_api_account_url(buyer_account_id) if buyer_account_id
  end

  link :self do
    api_invoice_url(id) if id
  end

  link :payment_transactions do
    api_invoice_payment_transactions_url(id) if id
  end

  link :line_items do
    api_invoice_line_items_url(id) if id
  end

end
