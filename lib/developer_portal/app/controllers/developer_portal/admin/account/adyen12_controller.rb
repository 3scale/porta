module DeveloperPortal::Admin::Account
  class Adyen12Controller < PaymentDetailsBaseController
    DEFAULT_GATEWAY_ERROR_MESSAGE = "couldn't save the credit card details".freeze

    before_action :payment_gateway_configured

    def show
      @gateway_options = site_account.payment_gateway_options
      render template: 'accounts/payment_gateways/show'
    end

    def hosted_success
      if authorize_recurring_and_store_card_details
        flash[:success] = 'Credit Card details were saved correctly'
      else
        flash[:error] = adyen_error_message
      end
      redirect_to after_hosted_success_path
    end

    protected

    # Catch exception from ActiveMerchant::AdyenGateway Argument error
    # This is likely because the provider has chosen adyen
    # but did not fill in required fields aka payment_gateway_unconfigured?
    def authorize_recurring_and_store_card_details
      gateway_client.authorize_recurring_and_store_card_details(params['adyen-encrypted-data'], ip: request.remote_ip)
    rescue ArgumentError => e
      raise e unless e.message.start_with? 'Missing required parameter:'
    end

    def gateway_client
      @gateway_client ||= ::PaymentGateways::Adyen12Crypt.new(current_user)
    end

    def adyen_error_message
      error_message = Payment::Adyen12ErrorsHandler.new(gateway_client.authorize_response).messages.first if gateway_client.authorize_response
      error_message || DEFAULT_GATEWAY_ERROR_MESSAGE
    end

    def payment_gateway_configured
      unless site_account.payment_gateway_configured?
        flash[:error] = DEFAULT_GATEWAY_ERROR_MESSAGE
        redirect_to root_path
      end
    end
  end
end
