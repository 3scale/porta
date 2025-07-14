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
      when ActiveMerchant::Billing::AuthorizeNetGateway
        charge_with_authorize_net
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

    def charge_with_authorize_net
      profile_response = authorize_net_customer_profile
      return profile_response unless profile_response.success?

      payment_profiles = profile_response.params['profile']['payment_profiles']
      payment_profile = payment_profiles.is_a?(Array) ? payment_profiles[-1] : payment_profiles # payment_profiles can be a Hash or an Array of hashes
      payment_profile_id = payment_profile['customer_payment_profile_id']

      gateway.cim_gateway.create_customer_profile_transaction({
                                                                transaction: {
                                                                  customer_profile_id: buyer_reference,
                                                                  customer_payment_profile_id: payment_profile_id,
                                                                  type: :auth_capture,
                                                                  amount: amount.to_f
                                                                }
                                                              })
    end

    def authorize_net_customer_profile
      gateway.cim_gateway.get_customer_profile(customer_profile_id: buyer_reference)
    end

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

# Monkey patch to turn all AuthorizeNet gateway clients into AuthorizeNetCim ones
class ::ActiveMerchant::Billing::AuthorizeNetGateway
  def cim_gateway
    @cim_gateway ||= ::ActiveMerchant::Billing::AuthorizeNetCimGateway.new(options)
  end
end
