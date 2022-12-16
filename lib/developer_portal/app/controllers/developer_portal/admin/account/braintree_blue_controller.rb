module DeveloperPortal::Admin::Account
  class BraintreeBlueController < PaymentDetailsBaseController
    def show
      render template: "accounts/payment_gateways/show"
    end

    def edit
      begin
        braintree_blue_crypt.create_customer_data
        @braintree_authorization = braintree_blue_crypt.authorization

        render template: "accounts/payment_gateways/edit"
      rescue Braintree::ConfigurationError, Braintree::AuthenticationError
        flash[:error] = 'Invalid merchant id'
        redirect_to action: :show
      end
      @errors = params[:errors]
    end

    def hosted_success
      customer_info      = params.require(:customer).permit!.to_h
      braintree_response = braintree_blue_crypt.confirm(customer_info, params.require(:braintree).require(:nonce))
      @payment_result    = braintree_response&.success?
      if @payment_result
        update_user_and_perform_action!(braintree_response)
      else
        @errors = braintree_response ? braintree_blue_crypt.errors(braintree_response) : ['Invalid Credentials']
        flash[:notice] = 'Credit card details could not be stored.'
        redirect_to action: 'edit', errors: @errors
      end
    end

    protected

    def update_user_and_perform_action!(result)
      if braintree_blue_crypt.update_user(result)
        flash[:success] = 'Credit card details were successfully stored.'
        redirect_to after_hosted_success_path, notice: 'Credit card details were successfully stored.'
      else
        flash[:notice] = 'Credit Card details could not be stored.'
        render template: 'accounts/payment_gateways/edit'
      end
    end

    def braintree_blue_crypt
      @braintree_blue_crypt ||= ::PaymentGateways::BrainTreeBlueCrypt.new(current_user)
    end

    def after_hosted_success_without_plan_changes_path
      admin_account_braintree_blue_url
    end
  end
end
