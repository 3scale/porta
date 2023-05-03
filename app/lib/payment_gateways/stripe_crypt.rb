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

      payment_detail.credit_card_expires_on     = Date.new(card.exp_year, card.exp_month)
      payment_detail.credit_card_partial_number = card.last4
      payment_detail.credit_card_auth_code      = payment_method.customer
      payment_detail.payment_method_id          = payment_method_id
      payment_detail.save
    end

    def create_stripe_setup_intent
      if customer.present?
        setup_intent_params = {
          payment_method_types: ['card'],
          usage: 'off_session',
          customer: customer.id
        }
        Stripe::SetupIntent.create(setup_intent_params, api_key)
      end
    end

    def customer
      @customer ||= find_or_create_customer
    end

    private

    delegate :payment_detail, to: :account

    def find_or_create_customer
      customer_id = payment_detail.credit_card_auth_code
      return create_customer if customer_id.blank?

      begin
        customer = Stripe::Customer.retrieve(customer_id, api_key)
        customer.deleted? ? create_customer : customer
      rescue Stripe::InvalidRequestError => e
        puts "An invalid request occurred."
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
