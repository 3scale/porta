class DeveloperPortal::Admin::Account::InvoicesController < ::DeveloperPortal::BaseController

  helper Finance::InvoicesHelper
  helper Accounts::InvoicesHelper

  before_action :authorize_finance
  before_action :find_provider
  activate_menu :account, :invoices

  liquify prefix: 'invoices'

  def index
    collection = current_account.invoices.visible_for_buyer.page(params[:page])

    invoices = Liquid::Drops::Invoice.wrap(collection)
    pagination = Liquid::Drops::Pagination.new(collection, self)
    assign_drops invoices: invoices, pagination: pagination
  end

  def show
    invoice = current_account.invoices.visible_for_buyer.find(params[:id])
    assign_drops invoice: Liquid::Drops::Invoice.wrap(invoice)
  end

  protected

  def authorize_finance
    authorize! :read, Invoice
  end

  def find_provider
    @provider = site_account
  end
end
