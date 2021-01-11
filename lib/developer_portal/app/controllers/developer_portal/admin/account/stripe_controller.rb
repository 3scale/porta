# frozen_string_literal: true

module DeveloperPortal::Admin::Account
  class StripeController < PaymentDetailsBaseController

    def show
      @stripe_publishable_key = site_account.payment_gateway_options[:publishable_key]
      @intent = stripe_crypt.create_stripe_setup_intent
      render template: 'accounts/payment_gateways/show'
    end

    def hosted_success
      payment_method_id = params.require(:stripe).require(:payment_method_id)
      @payment_result = stripe_crypt.update!(payment_method_id)

      if @payment_result
        flash[:success] = 'Credit card details were saved correctly'
      else
        flash[:error] = "Couldn't save the credit card details: #{stripe_crypt.errors.full_messages.to_sentence}"
      end
      redirect_to after_hosted_success_path
    end

    private

    def stripe_crypt
      @stripe_crypt ||= ::PaymentGateways::StripeCrypt.new(current_user)
    end
  end
end
