# frozen_string_literal: true

class DeveloperPortal::Admin::Account::InvoicesController < ::DeveloperPortal::BaseController
  class PaymentGatewayNotSupported < StandardError; end

  rescue_from PaymentGatewayNotSupported, with: :handle_not_found

  helper Finance::InvoicesHelper

  before_action :authorize_finance
  before_action :find_provider
  before_action :authorize_payment_gateway, only: %i[payment payment_succeeded]

  activate_menu :account, :invoices

  liquify prefix: 'invoices'

  def index
    collection = accessible_invoices.page(params[:page])
    invoices = Liquid::Drops::Invoice.wrap(collection)
    pagination = Liquid::Drops::Pagination.new(collection, self)
    assign_drops invoices: invoices, pagination: pagination
  end

  def show
    assign_drops invoice: Liquid::Drops::Invoice.wrap(find_invoice)
  end

  def payment
    @invoice = find_invoice
    payment_intent = @invoice.payment_intents.pending.latest.first!
    @client_secret = retrieve_stripe_payment_intent(payment_intent).client_secret
    @stripe_publishable_key = payment_gateway_options[:publishable_key]
  end

  def payment_succeeded
    invoice = find_invoice
    payment_intent = invoice.payment_intents.find_by!(reference: stripe_payment_intent_params[:id])
    service = Finance::StripePaymentIntentUpdateService.new(site_account, retrieve_stripe_payment_intent(payment_intent))

    if service.call
      flash[:notice] = 'Payment transaction updated'
    else
      flash[:error] = 'Failed to update payment transaction'
    end

    redirect_to admin_account_invoice_path(invoice)
  end

  protected

  def authorize_finance
    authorize! :read, Invoice
  end

  def authorize_payment_gateway
    return if payment_gateway_type.to_s =~ /stripe.*/
    raise PaymentGatewayNotSupported
  end

  def find_provider
    @provider = site_account
  end

  def accessible_invoices
    current_account.invoices.visible_for_buyer
  end

  def find_invoice
    accessible_invoices.find(params[:id])
  end

  attr_reader :invoice, :payment_intent

  delegate :payment_gateway_type, :payment_gateway_options, to: :site_account

  def api_key
    payment_gateway_options[:login]
  end

  def stripe_payment_intent_params
    params.require(:payment_intent).permit(:id)
  end

  def retrieve_stripe_payment_intent(payment_intent)
    Stripe::PaymentIntent.retrieve(payment_intent.reference, api_key)
  end
end
