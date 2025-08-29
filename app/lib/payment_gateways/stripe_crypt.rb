# frozen_string_literal: true

module PaymentGateways
  class StripeCrypt < PaymentGatewayCrypt
    attr_reader :errors

    # TODO: move Errors to payment gateway base and make others use it
    extend ActiveModel::Naming

    def initialize(user)
      super
      @errors = ActiveModel::Errors.new(self)
    end

    def update_payment_detail(payment_method_id)
      payment_method = Stripe::PaymentMethod.retrieve(payment_method_id, api_key)
      card = payment_method.card

      payment_detail.credit_card_expires_on     = Date.new(card.exp_year, card.exp_month)
      payment_detail.credit_card_partial_number = card.last4
      payment_detail.credit_card_auth_code      = payment_method.customer
      payment_detail.payment_method_id          = payment_method_id
      payment_detail.save!
    rescue StandardError
      @errors = payment_detail.errors
      false
    end

    def create_stripe_setup_intent
      setup_intent_params = {
        payment_method_types: ['card'],
        usage: 'off_session',
        customer: customer.id
      }
      Stripe::SetupIntent.create(setup_intent_params, api_key)
    end

    def customer
      @customer ||= find_or_create_customer
    end

    def update_billing_address(billing_address)
      current_payment_method_id = account.payment_detail&.payment_method_id
      return true unless current_payment_method_id

      payment_method = Stripe::PaymentMethod.retrieve(current_payment_method_id, api_key)

      payment_method.billing_details = {
        address: {
          line1: billing_address[:address1],
          line2: billing_address[:address2],
          city: billing_address[:city],
          state: billing_address[:state],
          postal_code: billing_address[:zip],
          country: billing_address[:country]
        }
      }
      payment_method.save
    rescue Stripe::StripeError => exception
      report_error("Failed to update billing address on Stripe: #{exception.message}")
    end

    private

    delegate :payment_detail, to: :account

    def find_or_create_customer
      customer_id = payment_detail.credit_card_auth_code
      return create_customer if customer_id.blank?

      begin
        customer = Stripe::Customer.retrieve(customer_id, api_key)
        return create_customer if customer.deleted?

        customer
      rescue Stripe::InvalidRequestError
        create_customer
      end
    end

    def create_customer
      customer_params = {
        description: account.org_name,
        email: user.email,
        metadata: { '3scale_account_reference' => buyer_reference }
      }

      Stripe::Customer.create(customer_params, api_key).tap { |stripe_customer| payment_detail.update(credit_card_auth_code: stripe_customer.id) }
    end

    def api_key
      payment_gateway_options.fetch(:login)
    end

    def report_error(message)
      @errors.add(:base, message)
      false
    end
  end
end
