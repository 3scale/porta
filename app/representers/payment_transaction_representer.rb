module PaymentTransactionRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id

  property :created_at
  property :updated_at

  property :reference
  property :success
  property :amount
  property :currency
  property :action
  property :message
  property :test

  def amount
    super.to_f
  end

  link :invoice do
    api_invoice_url(invoice_id) if invoice_id
  end

  link :account do
    admin_api_account_url(account_id) if account_id
  end


end
