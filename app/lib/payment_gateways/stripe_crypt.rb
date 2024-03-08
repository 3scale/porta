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

    def update!(payment_method_id)
      payment_method = Stripe::PaymentMethod.retrieve(payment_method_id, api_key)
      card = payment_method.card

      update_payment_detail(card, payment_method_id, payment_method)
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
      begin
        Stripe.api_key = api_key  # Set actual Stripe secret key

        latest_payment_method_id = latest_payment_method_id_for_customer
        return true unless latest_payment_method_id.present?

        payment_method = retrieve_payment_method(latest_payment_method_id)

        update_billing_details(payment_method, billing_address)
        payment_method.save
      rescue Stripe::StripeError => stripe_error
        handle_stripe_error(stripe_error)
      ensure
        reset_stripe_api_key
      end
    end

    private

    delegate :payment_detail, to: :account

    def find_or_create_customer
      customer_id = payment_detail.credit_card_auth_code
      return create_customer if customer_id.blank?

      retrieve_customer(customer_id)
    end

    def retrieve_customer(customer_id)
      customer = Stripe::Customer.retrieve(customer_id, api_key)

      return create_customer if customer.nil? || customer.deleted?

      customer
    rescue Stripe::InvalidRequestError
      create_customer
    end

    def create_customer
      customer_params = {
        description: account.org_name,
        email: user.email,
        metadata: { '3scale_account_reference' => buyer_reference }
      }

      Stripe::Customer.create(customer_params, api_key).tap do |stripe_customer|
        payment_detail.update(credit_card_auth_code: stripe_customer.id)
      end
    end

    def api_key
      payment_gateway_options.fetch(:login)
    end

    def latest_payment_method_id_for_customer
      latest_payment_method = Stripe::PaymentMethod.list(
        customer: customer.id,
        type: 'card',
        limit: 1
      ).data.first&.id
    end

    def report_error(message)
      @errors.add(:base, message)
      false
    end
  end
end
