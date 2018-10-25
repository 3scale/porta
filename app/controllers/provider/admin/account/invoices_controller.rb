class Provider::Admin::Account::InvoicesController < Provider::Admin::Account::BaseController

  helper Finance::InvoicesHelper
  helper Accounts::InvoicesHelper

  before_action :authorize_finance
  prepend_before_action :deny_on_premises
  activate_menu :account, :billing, :invoices

  def index
    @invoices = current_account.invoices
  end

  def show
    @invoice = current_account.invoices.find(params[:id])
  end

  protected

  def authorize_finance
    authorize! :read, Invoice
  end


end
