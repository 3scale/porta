# frozen_string_literal: true

class Master::ServiceDiscovery::AuthController < Master::BaseController
  include SiteAccountSupport
  def show
    self_domain = params.require(:self_domain)

    redirect_to self_domain_url(self_domain)
  end

  protected

  def self_domain_url(self_domain)
    options = params.except(:self_domain, :scope).merge(host: self_domain, controller: 'provider/admin/service_discovery/auth')
    url_for(options)
  end
end
