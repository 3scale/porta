# frozen_string_literal: true

class Finance::StripeChargeService
  PAYMENT_INTENT_SUCCEEDED = 'succeeded'
  PAYMENT_INTENT_REQUIRES_CONFIRMATION = 'requires_confirmation'
  PAYMENT_DESCRIPTION = 'API services'

  def initialize(gateway, payment_method_id:, invoice: nil, gateway_options: {})
    @gateway = gateway
    @payment_method_id = payment_method_id
    @invoice = invoice
    @gateway_options = gateway_options

    # As per Indian regulations the Payment intents should have a description,
    # see https://stripe.com/docs/india-accept-international-payments#valid-charges
    @gateway_options[:description] = charge_description
  end

  attr_reader :gateway, :payment_method_id, :invoice, :gateway_options

  def charge(amount)
    payment_intent = latest_pending_payment_intent
    payment_intent ? confirm_payment_intent(payment_intent) : create_payment_intent(amount)
  end

  protected

  delegate :latest_pending_payment_intent, to: :invoice, allow_nil: true

  def create_payment_intent(amount)
    response = gateway.purchase(amount.cents, payment_method_id, gateway_options)

    with_payment_intent_data_from(response) do |payment_intent_data|
      next unless invoice

      payment_intent = invoice.payment_intents.create!(reference: payment_intent_data['id'], state: payment_intent_data['status'])

      # For PaymentIntent statuses and corresponding recommended actions see https://stripe.com/docs/payments/accept-a-payment-synchronously
      # - succeeded                => no additional action > the payment has succeeded
      # - requires_confirmation    => confirm the payment intent
      # - requires_action          => check `payment_intent_data['next_action']` for instructions
      # - requires_payment_method  => do not retry > the payment attempt has failed > ask cardholder to replace card data

      case payment_intent.state
      when PAYMENT_INTENT_SUCCEEDED
        next
      when PAYMENT_INTENT_REQUIRES_CONFIRMATION
        confirm_payment_intent(payment_intent)
      end
    end
  end

  def confirm_payment_intent(payment_intent)
    # Passing the gateway option `off_session: false` will cause a `requires_action` status on the payment intent in cases where otherwise it would be `requires_payment_method`.
    # This happens even when the payment intent has been originally created with `off_session: true` - i.e. Stripe allows us to turn an "off_session" payment intent into an "on_session" one.
    # Along with the `requires_action` status, the param `next_action.use_stripe_sdk.stripe_js` holds the next-step link to get the transaction authenticated
    response = gateway.confirm_intent(payment_intent.reference, payment_method_id, gateway_options)

    with_payment_intent_data_from(response) do |payment_intent_data|
      payment_intent_status = payment_intent_data['status']
      payment_intent.update!(state: payment_intent_status)

      next if payment_intent_status == PAYMENT_INTENT_SUCCEEDED || !response.success?

      # Because in some cases Stripe won't wrap the response of `/payment_intents/:id/confirm` into an 'error' and ActiveMerchant may think it was a success when it wasn't.
      # See https://github.com/activemerchant/active_merchant/blob/b2f5e89eb383429d47e446f248d7bfe4f95ac3d0/lib/active_merchant/billing/gateways/stripe_payment_intents.rb#L299-L307
      response.instance_variable_set(:@success, false)
      response.instance_variable_set(:@message, payment_intent_status.humanize)
    end
  end

  def with_payment_intent_data_from(response)
    payment_intent_data = extract_payment_intent_data_from(response)
    yield(payment_intent_data) if payment_intent_data.present?
    response
  end

  def extract_payment_intent_data_from(response)
    response_params = response.params
    payment_intent_data = (response.success? ? response_params : response_params.dig('error', Stripe::PaymentIntent::OBJECT_NAME)) || {}
    payment_intent_data if payment_intent_data['object'] == Stripe::PaymentIntent::OBJECT_NAME
  end

  def charge_description
    return PAYMENT_DESCRIPTION if invoice.blank?

    "#{invoice&.from&.name} #{PAYMENT_DESCRIPTION} #{invoice&.friendly_id}".strip
  end
end
