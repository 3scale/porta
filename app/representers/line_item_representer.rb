module LineItemRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :name
  property :description
  property :quantity
  property :cost
  property :metric_id
  property :type

  property :contract_id
  property :contract_type
  property :plan_id

  property :created_at
  property :updated_at

  def cost
    super.to_f
  end

  link :application do
    admin_api_account_application_url(buyer_account, contract_id) if buyer_account && contract_id
  end

  link :invoice do
    api_account_invoice_url(buyer_account, invoice_id) if buyer_account && invoice_id
  end


end
