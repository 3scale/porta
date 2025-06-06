# frozen_string_literal: true

module DeveloperPortal::Admin::Account
  class AuthorizeNetController < PaymentDetailsBaseController
    def show
      authorize_net.create_profile unless current_account.credit_card_authorize_net_profile_stored?
      assign_template_variables

      render template: 'accounts/payment_gateways/show'
    rescue ::PaymentGateways::PaymentGatewayDown, ::PaymentGateways::IncorrectKeys => e
      @errors = e.message
      render action: 'credit_card_error'
    end

    def hosted_success
      cim_gateway = site_account.payment_gateway.cim_gateway
      customer = current_account.credit_card_auth_code
      auth_response = cim_gateway.get_customer_profile(customer_profile_id: customer)

      if authorize_net.has_credit_card?(auth_response)
        authorize_net.update_user(auth_response)
        flash[:notice] = 'Credit Card details were saved correctly'
      else
        delete_profile(cim_gateway, customer)
      end
      redirect_to after_hosted_success_path
    end

    private

    def delete_profile(cim_gateway, customer)
      cim_gateway.delete_customer_profile(customer_profile_id: customer)
      authorize_net.delete_user_profile
    end

    def authorize_net
      @authorize_net ||= ::PaymentGateways::AuthorizeNetCimCrypt.new(current_user)
    end

    def assign_template_variables
      assign_token
      assign_form_url
      assign_payment_profile_id
    end

    def assign_token
      @token = authorize_net
               .get_token(
                 login: site_account.payment_gateway.options[:login],
                 trans_key: site_account.payment_gateway.options[:password],
                 profile_id: current_account.credit_card_auth_code,
                 ok_url: hosted_success_admin_account_authorize_net_url
               )
    end

    def assign_form_url
      @form_url = authorize_net.action_form_url
    end

    def assign_payment_profile_id
      @payment_profile_id = authorize_net.payment_profile
    end
  end
end
