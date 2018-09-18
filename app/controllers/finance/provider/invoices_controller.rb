class Finance::Provider::InvoicesController < Finance::Provider::BaseController
  activate_menu :finance, :invoices

  helper Finance::InvoicesHelper
  helper ColumnSortingHelper
  include ThreeScale::Search::Helpers
  helper_method :allow_edit?

  before_action :find_buyer, only: [ :create ]
  before_action :find_invoice, except: [ :index, :create ]

  def index
    @search = ThreeScale::Search.new(params[:search] || params)
    @invoices = collection.scope_search(@search).order_by(params[:sort], params[:direction]).paginate(paginate_params)
  end

  def create
    current_account.billing_strategy.create_invoice!(buyer_account: @buyer,
                                                     period: Month.new(Time.now.utc))
    respond_to do |format|
      format.js { flash.now[:notice] = 'Invoice successfully created.' }
    end
  end

  def show
    unless @invoice
      render_error("Invoice not found", status: :not_found)
      return false
    end

    respond_to do |format|
      format.html
      format.json { render json: @invoice.to_json }
      format.js   { render json: @invoice.to_json }
      format.pdf  { redirect_to @invoice.pdf.url     }
    end
  end

  [ [ :pay, 'Invoice marked as "paid".', 'Failed to mark invoice as paid.' ],
    [ :generate_pdf, 'PDF generated.', 'Failed to generate the PDF' ],
    [ :cancel, 'Invoice cancelled.', 'Failed to cancel the invoice' ],
    [ :issue, 'Invoice issued.', 'Failed to issue the invoice' ],
    [ :charge, 'Payment successfully completed!', 'Failed to charge the credit card.', false]
  ].each do |action,success,error, *opts|
    define_method(action) do
      invoice_action(action, success, error, *opts)
    end
  end

  def edit
    unless @invoice.editable?
      redirect_to admin_finance_invoice_url(@invoice), alert: 'Invoice is no longer editable.'
    end
  end

  def update
    # TODO: enable this when we permit to edit due on date
    #if due = params[:invoice][:due_on].presence
    #  @invoice.due_on = due
    #end

    if @invoice.update_attributes(params[:invoice])
      redirect_to admin_finance_invoice_url(@invoice), notice: 'Invoice was successfully updated.'
    else
      render :edit
    end
  end

  private

  def invoice_action(action, success_message, error_message, *action_params)
    if @invoice.transition_allowed?(action) && @invoice.send("#{action}!", *action_params)
      @header = render_headers_to_string
      @actions = render_actions_to_string
      @line_items = render_line_items_to_string
      flash.now[:notice] = success_message

      respond_to do |format|
        format.js do 
          render :partial => '/finance/provider/shared/update_invoice',
                           :locals => { :editable => allow_edit? } 
        end
      end
    else
      flash.now[:error] = error_message
      render :partial => '/shared/flash_message'
    end
  end

  def render_headers_to_string
    render_to_string(:partial => "/finance/provider/shared/invoice_header",
                                 :locals => { :editable => allow_edit?, edit_link_scope: [:finance] })
  end

  def render_line_items_to_string
    render_to_string(:partial => "/finance/provider/shared/line_items",
                                 :locals => { :editable => allow_edit? })
  end

  def render_actions_to_string
    render_to_string(:partial => "/finance/provider/invoices/actions")
  end

  def allow_edit?
    !@invoice.buyer_account.nil?
  end

  def paginate_params
    { :page => params[:page] || 1, :per_page => 20 }
  end

  def collection
     @collection ||= if params[:account_id]
                        find_buyer.invoices
                     else
                        current_account.buyer_invoices.includes(:provider_account)
                      end
  end

  def find_buyer(options = {})
    @buyer ||= current_account.buyer_accounts.where(options).find(params[:account_id])
  end

  def find_invoice
    @invoice = collection.find(params[:id])
  end
end
