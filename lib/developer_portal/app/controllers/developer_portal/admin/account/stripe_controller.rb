module DeveloperPortal::Admin::Account
  class StripeController < PaymentDetailsBaseController

    def show
      @stripe_publishable_key = site_account.payment_gateway_options[:publishable_key]
      render template: "accounts/payment_gateways/show"
    end

    def hosted_success
      stripe_crypt    = ::PaymentGateways::StripeCrypt.new(current_user)
      @payment_result = stripe_crypt.update!(params)

      if @payment_result
        flash[:success] = "Credit card details were saved correctly"
      else
        flash[:error] = "Couldn't save the credit card details: #{stripe_crypt.errors.full_messages.to_sentence}"
      end
      redirect_to after_hosted_success_path
    end
  end
end
