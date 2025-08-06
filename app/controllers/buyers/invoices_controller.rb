class Buyers::InvoicesController < Buyers::BaseController
  include Finance::ControllerRequirements
  helper Finance::InvoicesHelper
  helper Accounts::InvoicesHelper

  helper_method :allow_edit?

  before_action :authorize_finance
  before_action :find_account
  activate_menu :audience, :accounts, :listing

  def index
    @invoices = @account.invoices.includes(:provider_account).ordered
  end

  def show
    @invoice = @account.invoices.find(params[:id])
  end

  def create
    if @account.current_invoice.present?
      flash[:info] = t('.open_invoice', name: @account.name)
    else
      current_account.billing_strategy.create_invoice!(:buyer_account => @account,
                                                       :period => Month.new(Time.zone.now))
      flash[:success] = t('.success')
    end

    redirect_to admin_buyers_account_invoices_path(@account)
  end

  def edit
    @invoice = @account.invoices.find(params[:id])

    return if @invoice.editable?

    redirect_to admin_buyers_account_invoice_url(@account, @invoice), info: t('.error')
  end

  def update
    @invoice = @account.invoices.find(params[:id])

    if @invoice.update(params[:invoice])
      redirect_to admin_buyers_account_invoice_url(@account, @invoice), success: t('.success')
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
