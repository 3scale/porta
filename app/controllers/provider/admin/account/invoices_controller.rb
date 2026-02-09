class Provider::Admin::Account::InvoicesController < Provider::Admin::Account::BaseController

  helper Finance::InvoicesHelper

  before_action :authorize_finance
  prepend_before_action :deny_on_premises
  activate_menu :account, :billing, :invoices
  helper_method :empty_invoices?

  def index
    @invoices = current_account.invoices.ordered
  end

  def show
    @invoice = current_account.invoices.find(params.require(:id))
  end

  protected

  def authorize_finance
    authorize! :read, Invoice
  end

  def empty_invoices?
    @invoices.blank?
  end

end
