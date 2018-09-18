module DeveloperPortal::Admin::Account
  class OgoneController < PaymentDetailsBaseController
    def show
      ogone_crypt = ::PaymentGateways::OgoneCrypt.new(current_user)
      @ogone_url =  ogone_crypt.url
      ogone_crypt.fill_fields(hosted_success_admin_account_ogone_url)
      @fields = ogone_crypt.fields
      @ogone_pspid =  site_account.payment_gateway_options[:pspid]
      render template: 'accounts/payment_gateways/show'
    end

    def hosted_success
      ogone_crypt = ::PaymentGateways::OgoneCrypt.new(current_user)
      if ogone_crypt.success?(request.params)
        ogone_crypt.update_user(request.params)
        flash[:success] = 'Credit Card details were saved correctly'
      else
        flash[:error] = "couldn't save the credit card details"
      end
      redirect_to after_hosted_success_path
    end
  end
end
