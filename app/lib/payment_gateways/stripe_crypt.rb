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

    def update!(params)
      payment_method_id = params.require(:stripe).require(:payment_method_id)
      payment_method = Stripe::PaymentMethod.retrieve(payment_method_id, api_key)
      card = payment_method.card

      account.credit_card_expires_on_month = card.exp_month
      account.credit_card_expires_on_year = card.exp_year
      account.credit_card_partial_number = card.last4
      account.credit_card_auth_code = payment_method.customer
      account.payment_method_id = payment_method_id
      account.save
    end

    def create_stripe_customer
      Stripe::Customer.create({
        description: account.org_name,
        email: user.email,
        metadata: {  '3scale_account_reference' => buyer_reference }
      }, api_key)
    end

    def create_stripe_setup_intent(customer = create_stripe_customer)
      Stripe::SetupIntent.create({
        payment_method_types: ['card'],
        usage: 'off_session',
        customer: customer.id
      }, api_key)
    end

    private

    def api_key
      payment_gateway_options.fetch(:login)
    end

    def report_error(message)
      @errors.add(:base, message)
      false
    end
  end
end
