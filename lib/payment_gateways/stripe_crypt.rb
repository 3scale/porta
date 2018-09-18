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
      stripe_params = params.require(:stripe)
      customer = create_stripe_customer(stripe_params)
      update_account(customer, stripe_params)
    rescue Stripe::CardError => error
      report_error(error.message)
    end

    def create_stripe_customer(stripe_params)
      token   = stripe_params.require(:token)
      api_key = payment_gateway_options.fetch(:login)
      Stripe::Customer.create({ card: token,
                                description: account.org_name,
                                email: user.email,
                                metadata: {
                                  '3scale_account_reference' => buyer_reference
                                }
                              }, api_key)
    end

    def update_account(customer, stripe_params)
      account.credit_card_expires_on_month = stripe_params.require(:expires_on_month)
      account.credit_card_expires_on_year = stripe_params.require(:expires_on_year)
      account.credit_card_partial_number = stripe_params.require(:partial_number)[-4..-1]
      account.credit_card_auth_code = customer.id
      account.save
    end

    private

    def report_error(message)
      @errors.add(:base, message)
      false
    end
  end
end
