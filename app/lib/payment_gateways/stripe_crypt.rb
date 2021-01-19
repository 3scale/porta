# frozen_string_literal: true

module PaymentGateways
  class StripeCrypt < PaymentGatewayCrypt
    attr_accessor :customer_id

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
      setup_intent_params = {
        payment_method_types: ['card'],
        usage: 'off_session',
        customer: find_or_create_customer.id
      }
      Stripe::SetupIntent.create(setup_intent_params, api_key)
    end

    private

    delegate :payment_detail, to: :account

    def customer_id
      payment_detail.credit_card_auth_code
    end

    def find_or_create_customer
      customer = Stripe::Customer.retrieve(customer_id, api_key) if customer_id
      customer.try(:id) ? customer : create_customer
    end

    def create_customer
      customer_params = {
        description: account.org_name,
        email: user.email,
        metadata: {  '3scale_account_reference' => buyer_reference }
      }

      Stripe::Customer.create(customer_params, api_key).tap do |customer|
        payment_detail.credit_card_auth_code = customer.id
        payment_detail.save
      end
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
