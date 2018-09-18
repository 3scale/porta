# frozen_string_literal: true

class Master::Redhat::AuthController < Master::BaseController
  include SiteAccountSupport
  include RedhatCustomerPortalSupport::ControllerMethods::AuthFlow

  def show
    self_domain = params.require(:self_domain)

    case ThreeScale.config.redhat_customer_portal.flow
    when 'auth_code'
      redirect_to self_domain_url(self_domain)
    when 'implicit'
      render layout: false
    else
      metadata = { params: request.params }
      raise ThreeScale::OAuth2::ClientBase::UnsupportedFlowError, metadata
    end
  end

  protected

  def self_domain_url(self_domain)
    options = params.except(:self_domain, :scope).merge(host: self_domain, controller: 'provider/admin/redhat/auth')
    url_for(options)
  end
end
