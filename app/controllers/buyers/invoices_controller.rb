class Buyers::InvoicesController < Buyers::BaseController
  helper Finance::InvoicesHelper
  helper Accounts::InvoicesHelper

  helper_method :allow_edit?

  before_action :find_account

  activate_menu :submenu => :accounts

  def index
    @invoices = @account.invoices.includes(:buyer_account, :provider_account)
  end

  def show
    @invoice = @account.invoices.find(params[:id])
  end

  def create
    current_account.billing_strategy.create_invoice!(:buyer_account => @account,
                                                     :period => Month.new(Time.zone.now))
    respond_to do |format|
      format.js   { flash.now[:notice] = 'Invoice successfully created.' }
      format.html do
        flash[:notice] = 'Invoice successfully created.'
        redirect_to admin_buyers_account_invoices_path(@account) 
      end
    end
  end

  def edit
    @invoice = @account.invoices.find(params[:id])

    unless @invoice.editable?
      redirect_to admin_buyers_account_invoice_url(@account, @invoice), alert: 'Invoice is no longer editable.'
    end
  end

  def update
    @invoice = @account.invoices.find(params[:id])

    if @invoice.update_attributes(params[:invoice])
      redirect_to admin_buyers_account_invoice_url(@account, @invoice), notice: 'Invoice was successfully updated.'
    else
      render :edit
    end
  end

  private
  def find_account
    @account = current_account.buyers.find(params[:account_id])
  end

  def allow_edit?
    !@invoice.buyer_account.nil?
  end

end
