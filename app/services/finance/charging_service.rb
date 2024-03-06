# frozen_string_literal: true

module Finance
  class ChargingService
    def initialize(gateway, buyer_reference:, amount:, options: {})
      @gateway = gateway
      @buyer_reference = buyer_reference
      @amount = amount
      @options = options
    end

    attr_reader :gateway, :buyer_reference, :amount, :options

    def call
      case gateway
      when ActiveMerchant::Billing::StripePaymentIntentsGateway
        charge_with_stripe_payment_intents
      when ActiveMerchant::Billing::StripeGateway
        charge_with_stripe
      when ActiveMerchant::Billing::BraintreeBlueGateway
        charge_with_braintree_blue
      else
        gateway.purchase(amount.cents, buyer_reference, options)
      end
    end

    protected

    def charge_with_stripe(opts = options)
      options = opts.merge(customer: buyer_reference)
      payment_method_id = options.delete(:payment_method_id)
      invoice = options.delete(:invoice)
      stripe_service = Finance::StripeChargeService.new(gateway, payment_method_id: payment_method_id, invoice: invoice, gateway_options: options)
      stripe_service.charge(amount)
    end

    def charge_with_stripe_payment_intents
      charge_with_stripe(options.reverse_merge(off_session: true, execute_threed: true))
    end

    def charge_with_braintree_blue
      gateway.purchase(amount.cents, buyer_reference, options.merge(transaction_source: 'unscheduled'))
    end
  end
end
