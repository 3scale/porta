class Finance::Api::InvoicesController < Finance::Api::BaseController

  representer ::Invoice

  paginate only: :index

  STATES = Hash.new {|_, k| k}.merge('cancel' => 'cancelled').freeze

  # Invoice List
  # GET  /api/invoices.xml
  def index
    search = ThreeScale::Search.new(params[:search] || params)
    results = invoices.scope_search(search)
                .order_by(params[:sort], params[:direction])
                .paginate(pagination_params)

    respond_with(results)
  end

  # Invoice Read
  # GET /api/invoices/{id}.xml
  def show
    respond_with(invoice) do |format|
      format.pdf { redirect_to invoice.pdf.expiring_url }
    end
  end

  # Invoice Update state
  # PUT /api/invoices/{id}/state.xml
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

  # Invoice Charge
  # POST /api/invoices/{id}/charge.xml
  def charge
    errors = invoice.errors
    if invoice.transition_allowed?(:charge)
      errors.add(:base, :charging_failed) unless invoice.charge!(false)
    else
      errors.add(:state, :not_in_chargeable_state, id: invoice.id)
    end
    respond_with(invoice)
  end

  # Invoice Update
  # PUT /api/invoices/{id}.xml
  def update
    invoice.update(invoice_params_update, without_protection: true)
    respond_with(invoice)
  end

  # Invoice Create
  # POST /api/invoices.xml
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
