# frozen_string_literal: true

class Finance::Api::PaymentCallbacks::StripeCallbacksController < Finance::Api::BaseController
  before_action :ensure_stripe_payment_gateway

  class StripeCallbackError < StandardError; end
  class InvalidStripeEvent < StripeCallbackError; end
  class MissingStripeEndpointSecret < StripeCallbackError; end

  # Undocumented endpoint used for update callbacks of async-authorized payment transactions (mostly due to SCA regulations)
  def create
    sig_header = request.headers['Stripe-Signature']
    endpoint_secret = payment_gateway_options[:endpoint_secret].presence

    raise MissingStripeEndpointSecret unless endpoint_secret

    stripe_event = Stripe::Webhook.construct_event(request.raw_post, sig_header, endpoint_secret)
    payment_intent_data = case stripe_event.type # Also checked by PaymentIntent#update_from_stripe_event, but here it can save us some processing and ensure an immediate response at the level of the controller in case of unsupported event types
                          when 'payment_intent.succeeded'
                            stripe_event.data.object
                          else
                            raise InvalidStripeEvent
                          end

    payment_intent = PaymentIntent.by_invoice(current_account.buyer_invoices).find_by!(payment_intent_id: payment_intent_data['id'])

    unless payment_intent.update_from_stripe_event(stripe_event)
      exception = StripeCallbackError.new('Cannot update Stripe payment intent')
      report_error(exception, event: stripe_event, payment_intent: payment_intent)
    end

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    render_error('Signature verification failed', status: :bad_request)
  rescue InvalidStripeEvent
    render_error(:not_found, status: :not_found)
  rescue MissingStripeEndpointSecret => exception
    report_error(exception)
    render_error('Configuration is missing', status: :unprocessable_entity)
  end

  protected

  def ensure_stripe_payment_gateway
    return if payment_gateway_type == :stripe
    render_error(:not_found, status: :not_found)
    false
  end

  delegate :payment_gateway_type, :payment_gateway_options, to: :current_account

  delegate :report_error, to: System::ErrorReporting
end
