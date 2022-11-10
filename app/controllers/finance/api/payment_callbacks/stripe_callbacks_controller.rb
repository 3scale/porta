# frozen_string_literal: true

class Finance::Api::PaymentCallbacks::StripeCallbacksController < Finance::Api::BaseController
  before_action :ensure_stripe_payment_gateway
  before_action :validate_stripe_event_type

  class StripeCallbackError < StandardError; end
  class InvalidStripeEvent < StripeCallbackError; end
  class MissingStripeEndpointSecret < StripeCallbackError; end

  rescue_from Stripe::SignatureVerificationError, JSON::ParserError do
    render_error('Signature verification failed', status: :bad_request)
  end

  rescue_from InvalidStripeEvent, with: :handle_not_found

  rescue_from MissingStripeEndpointSecret do |e|
    report_error(e)
    render_error('Configuration is missing', status: :unprocessable_entity)
  end

  # Undocumented endpoint used for update callbacks of async-authorized payment transactions (mostly due to SCA regulations)
  def create
    service = begin
      Finance::StripePaymentIntentUpdateService.new(current_account, stripe_event)
    rescue ActiveRecord::RecordNotFound
      # Returning 204 to acknowledge reception even for payments we don't care about.
      #
      # There are some clients who are using their Stripe account not only for 3Scale,
      # but also for other services they provide. When they receive any payment, Stripe
      # will call all webhooks, no matter where the payment comes from, and we'll
      # receive a call for a payment not managed by us. Stripe expects us to return 204
      # in this situation, since they will remove the webhook if it returns error codes
      # too often.
      #
      # https://issues.redhat.com/browse/THREESCALE-6851
      nil
    end

    return head(:no_content) if service.blank? || service.call

    exception = StripeCallbackError.new('Cannot update Stripe payment intent')
    report_error(exception, event: stripe_event, payment_intent: service.payment_intent)
  end

  protected

  PAYMENT_INTENT_SUCCEEDED = [Stripe::PaymentIntent::OBJECT_NAME, Finance::StripeChargeService::PAYMENT_INTENT_SUCCEEDED].join('.').freeze
  ALLOWED_STRIPE_EVENT_TYPES = [PAYMENT_INTENT_SUCCEEDED].freeze

  delegate :report_error, to: System::ErrorReporting
  delegate :payment_gateway_type, :payment_gateway_options, to: :current_account

  def ensure_stripe_payment_gateway
    return if payment_gateway_type == :stripe

    render_error(:not_found, status: :not_found)
  end

  def stripe_event
    @stripe_event ||= begin
      endpoint_secret = payment_gateway_options[:endpoint_secret].presence
      raise MissingStripeEndpointSecret unless endpoint_secret

      Stripe::Webhook.construct_event(request.raw_post, request.headers['Stripe-Signature'], endpoint_secret)
    end
  end

  def validate_stripe_event_type
    raise InvalidStripeEvent unless ALLOWED_STRIPE_EVENT_TYPES.include?(stripe_event.type)
  end
end
