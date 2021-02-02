# frozen_string_literal: true

class DeveloperPortal::Admin::Account::InvoicesController < ::DeveloperPortal::BaseController
  helper Finance::InvoicesHelper
  helper Accounts::InvoicesHelper

  before_action :authorize_finance
  before_action :find_provider
  before_action :find_invoice, only: %i[show payment payment_succeeded]
  activate_menu :account, :invoices

  liquify prefix: 'invoices'

  def index
    collection = accessible_invoices.page(params[:page])
    invoices = Liquid::Drops::Invoice.wrap(collection)
    pagination = Liquid::Drops::Pagination.new(collection, self)
    assign_drops invoices: invoices, pagination: pagination
  end

  def show
    assign_drops invoice: Liquid::Drops::Invoice.wrap(invoice)
  end

  def payment
    @payment_intent = @invoice.payment_intents.latest_pending.first!
    @client_secret = stripe_payment_intent.client_secret
    @stripe_publishable_key = payment_gateway_options[:publishable_key]
  end

  def payment_succeeded
    @payment_intent = @invoice.payment_intents.find_by!(reference: stripe_payment_intent_params[:id])

    service = Finance::StripePaymentIntentUpdateService.new(site_account, stripe_payment_intent)
    if service.call
      flash[:notice] = 'Payment succeeded'
    else
      flash[:error] = 'Payment failed'
    end

    redirect_to admin_account_invoice_path(@invoice)
  end

  protected

  def authorize_finance
    authorize! :read, Invoice
  end

  def find_provider
    @provider = site_account
  end

  def accessible_invoices
    current_account.invoices.visible_for_buyer
  end

  def find_invoice
    @invoice = accessible_invoices.find(params[:id])
  end

  attr_reader :invoice, :payment_intent

  delegate :payment_gateway_options, to: :site_account

  def api_key
    payment_gateway_options[:login]
  end

  def stripe_payment_intent_params
    params.require(:payment_intent).permit(:id)
  end

  def stripe_payment_intent
    Stripe::PaymentIntent.retrieve(payment_intent.reference, api_key)
  end
end
