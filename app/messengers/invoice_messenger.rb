class InvoiceMessenger < Messenger::Base
  class NotDeliverableError < StandardError; end

  def initialize(*args)
    super
  rescue NotDeliverableError
    # TODO: Should we notify this error or leave it in logs?
    Rails.logger.warn '~~~ InvoiceMessenger - either the buyer or the provider have been deleted.'
  end

  def deliver
    super if deliverable?
  end

  def setup(invoice)
    ensure_deliverable!(invoice)
    @invoice = invoice
    @buyer_account = invoice.buyer_account
    @cost = format_cost(@invoice.cost)

    @invoice_url = if @buyer_account.provider?
      app_routes.provider_admin_account_invoice_url(@invoice, :host => @buyer_account.self_domain)
                   else
      developer_portal_routes.admin_account_invoice_url(@invoice, :host => @invoice.provider_account.domain)
    end

    setup_drops
  end

  def upcoming_charge_notification(invoice)
    to_buyer(invoice, 'Monthly statement')
  end

  def successfully_charged(invoice)
    to_buyer(invoice, 'Payment completed')
  end

  def unsuccessfully_charged_for_buyer(invoice)
    @payment_url = payment_url(invoice)
    to_buyer(invoice, 'Problem with payment')
  end

  def unsuccessfully_charged_for_buyer_final(invoice)
    to_buyer(invoice, 'Problem with payment')
  end

  def unsuccessfully_charged_for_provider(invoice)
    to_provider(invoice, 'API System: User payment problem')
  end

  def unsuccessfully_charged_for_provider_final(invoice)
    to_provider(invoice, 'API System: User payment problem')
  end

  private

  def to_provider(invoice, reason)
    message(:to      => invoice.provider_account,
            :sender  => invoice.buyer_account,
            :subject => buyer_subject(invoice, reason))
  end

  def to_buyer(invoice, reason)
    message(:to      => invoice.buyer_account,
            :sender  => invoice.provider_account,
            :subject => buyer_subject(invoice, reason))
  end

  def sufix(attempt)
    (attempt >= 3) ? '_last' : ''
  end

  def buyer_subject(invoice, text)
    "#{invoice.provider_account.org_name} API - #{text}"
  end

  def format_cost(cost)
    number_to_currency(cost.amount, :unit => cost.currency, :format => "%u %n")
  end

  def payment_url(invoice)
    type = invoice.provider_account.payment_gateway_type.try!(:to_sym)

    return '' if type.nil? || type == :bogus

    if invoice.provider_account.master?
      app_routes.polymorphic_url([:provider, :admin, :account, type.to_sym],host: invoice.buyer_account.self_domain)
    else
      developer_portal_routes.polymorphic_url([:admin, :account, type.to_sym], host: invoice.provider_account.domain)
    end
  end

  def ensure_deliverable!(invoice)
    @_deliverable = invoice.provider_account.present? && invoice.buyer_account.present?
    raise NotDeliverableError, 'InvoiceMessenger cannot be delivered' unless @_deliverable
  end

  def deliverable?
    @_deliverable
  end

  def setup_drops
    assign_drops buyer_account: Liquid::Drops::Account.new(@buyer_account), # deprecated
                 account: Liquid::Drops::Account.new(@buyer_account),
                 provider: Liquid::Drops::Provider.new(@invoice.provider_account),
                 cost: @cost,
                 invoice_url: @invoice_url,
                 payment_url: payment_url(@invoice)
  end
end
