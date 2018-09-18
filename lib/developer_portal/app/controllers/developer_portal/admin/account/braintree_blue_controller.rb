module DeveloperPortal::Admin::Account
  class BraintreeBlueController < PaymentDetailsBaseController

    def show
      render template: "accounts/payment_gateways/show"
    end

    def edit
      begin
        @form_url = braintree_blue_crypt.form_url
        @tr_data = braintree_blue_crypt.create_customer_data(
            redirect_url: hosted_success_admin_account_braintree_blue_url)
        render template: "accounts/payment_gateways/edit"
      rescue Braintree::ConfigurationError, Braintree::AuthenticationError
        flash[:error] = 'Invalid merchant id'
        redirect_to action: :show
      end
      @errors = params[:errors]
    end

    def hosted_success
      result = braintree_blue_crypt.confirm(request)
      if result && result.success?
        update_user_and_perform_action!(result)
      else
        @errors = result ? braintree_blue_crypt.errors(result) : ['Invalid Credentials']
        flash[:notice] = 'Credit card details could not be stored.'
        redirect_to action: 'edit', errors: @errors
      end
    end

    protected

    def update_user_and_perform_action!(result)
      if braintree_blue_crypt.update_user(result)
        flash[:success] = 'Credit card details were successfully stored.'
        redirect_to after_hosted_success_path
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
