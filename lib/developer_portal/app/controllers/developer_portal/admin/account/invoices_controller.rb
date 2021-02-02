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

  def payment
    @invoice = current_account.invoices.visible_for_buyer.find(params[:id])
    @client_secret = fetch_stripe_client_secret
    @stripe_publishable_key = payment_gateway_options[:publishable_key]
  end

  protected

  def authorize_finance
    authorize! :read, Invoice
  end

  def find_provider
    @provider = site_account
  end

  delegate :payment_gateway_options, to: :site_account

  def payment_intent
    @payment_intent ||= @invoice.payment_intents.latest_pending.first
  end

  def api_key
    payment_gateway_options[:login]
  end

  def fetch_stripe_client_secret
    return unless payment_intent

    Stripe::PaymentIntent.retrieve(payment_intent.reference, api_key).client_secret
  end
end
